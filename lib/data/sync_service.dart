import 'package:sqflite/sqflite.dart';
import 'database.dart';

/// Backend adapter. Implement with Supabase/Firebase and register it via
/// `remoteGatewayProvider`. See README for a ~15 line Supabase example.
abstract class RemoteGateway {
  bool get isConfigured;

  /// Upserts [rows] of [table]; must be idempotent (rows carry stable ids).
  Future<void> upsert(String table, List<Map<String, Object?>> rows);

  /// Deletes rows of [table] by id.
  Future<void> remove(String table, List<String> ids);
}

class NoRemote implements RemoteGateway {
  @override
  bool get isConfigured => false;
  @override
  Future<void> upsert(String table, List<Map<String, Object?>> rows) async {}
  @override
  Future<void> remove(String table, List<String> ids) async {}
}

class SyncStatus {
  final int pending;
  final bool configured;
  const SyncStatus(this.pending, this.configured);
}

/// Local-first sync: every local write is already queued in `sync_outbox`.
/// This service drains the queue when a remote is configured. The app never
/// waits for it, so workouts are never blocked by connectivity.
class SyncService {
  final AppDatabase _app;
  final RemoteGateway remote;
  SyncService(this._app, this.remote);

  Future<SyncStatus> status() async {
    final db = await _app.db;
    final n = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM sync_outbox')) ?? 0;
    return SyncStatus(n, remote.isConfigured);
  }

  /// Pushes queued changes. Returns the number of entries synced.
  Future<int> syncNow() async {
    if (!remote.isConfigured) return 0;
    final db = await _app.db;
    final items = await db.query('sync_outbox', orderBy: 'id ASC');
    var done = 0;
    for (final it in items) {
      try {
        final entity = it['entity'] as String;
        final id = it['entity_id'] as String;
        if (it['op'] == 'delete') {
          for (final t in _tablesFor(entity)) {
            await remote.remove(t, [id]);
          }
        } else {
          await _push(db, entity, id);
        }
        await db.delete('sync_outbox', where: 'id = ?', whereArgs: [it['id']]);
        done++;
      } catch (_) {
        break; // keep the rest queued; retry next time (offline, auth, ...)
      }
    }
    return done;
  }

  List<String> _tablesFor(String entity) => switch (entity) {
        'workout' => ['workouts'],
        'exercise' => ['exercises'],
        'program' => ['programs'],
        'record' => ['personal_records'],
        'bodyweight' => ['bodyweight'],
        _ => const [],
      };

  Future<void> _push(Database db, String entity, String id) async {
    switch (entity) {
      case 'workout':
        await remote.upsert('workouts', await db.query('workouts', where: 'id = ?', whereArgs: [id]));
        final wes = await db.query('workout_exercises', where: 'workout_id = ?', whereArgs: [id]);
        await remote.upsert('workout_exercises', wes);
        if (wes.isNotEmpty) {
          final ids = wes.map((e) => e['id']).toList();
          await remote.upsert('workout_sets',
              await db.query('workout_sets', where: 'workout_exercise_id IN (${sqlIn(ids)})', whereArgs: ids));
        }
      case 'exercise':
        await remote.upsert('exercises', await db.query('exercises', where: 'id = ?', whereArgs: [id]));
      case 'record':
        await remote.upsert('personal_records', await db.query('personal_records', where: 'id = ?', whereArgs: [id]));
      case 'bodyweight':
        await remote.upsert('bodyweight', await db.query('bodyweight', where: 'id = ?', whereArgs: [id]));
      case 'program':
        await remote.upsert('programs', await db.query('programs', where: 'id = ?', whereArgs: [id]));
        final blocks = await db.query('program_blocks', where: 'program_id = ?', whereArgs: [id]);
        await remote.upsert('program_blocks', blocks);
        for (final b in blocks) {
          final days = await db.query('program_days', where: 'block_id = ?', whereArgs: [b['id']]);
          await remote.upsert('program_days', days);
          for (final d in days) {
            final exs = await db.query('program_exercises', where: 'day_id = ?', whereArgs: [d['id']]);
            await remote.upsert('program_exercises', exs);
            for (final e in exs) {
              await remote.upsert('program_sets',
                  await db.query('program_sets', where: 'program_exercise_id = ?', whereArgs: [e['id']]));
            }
          }
        }
    }
  }
}
