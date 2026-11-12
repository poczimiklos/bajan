import 'package:sqflite/sqflite.dart';
import '../database.dart';
import '../models.dart';

class ProgramRepository {
  final AppDatabase _app;
  ProgramRepository(this._app);

  Future<List<Program>> all() async {
    final db = await _app.db;
    final rows = await db.query('programs', where: 'deleted_at IS NULL', orderBy: 'is_sample ASC, name COLLATE NOCASE');
    final out = <Program>[];
    for (final r in rows) {
      out.add(await _load(r['id'] as String));
    }
    return out;
  }

  Future<Program?> load(String id) async {
    final db = await _app.db;
    final r = await db.query('programs', where: 'id = ? AND deleted_at IS NULL', whereArgs: [id]);
    return r.isEmpty ? null : _load(id);
  }

  Future<Program?> loadByBlock(String blockId) async {
    final db = await _app.db;
    final r = await db.query('program_blocks', columns: ['program_id'], where: 'id = ?', whereArgs: [blockId]);
    if (r.isEmpty) return null;
    return load(r.first['program_id'] as String);
  }

  Future<bool> existsByName(String name) async {
    final db = await _app.db;
    final r = await db.query('programs', where: 'name = ? AND deleted_at IS NULL', whereArgs: [name], limit: 1);
    return r.isNotEmpty;
  }

  Future<Program> _load(String id) async {
    final db = await _app.db;
    final pr = (await db.query('programs', where: 'id = ?', whereArgs: [id])).first;
    final program = Program(
      id: id,
      name: pr['name'] as String,
      description: (pr['description'] as String?) ?? '',
      isSample: (pr['is_sample'] as int? ?? 0) == 1,
    );
    final blocks = await db.query('program_blocks', where: 'program_id = ?', whereArgs: [id], orderBy: 'position');
    for (final b in blocks) {
      final block = ProgramBlock(
        id: b['id'] as String,
        name: b['name'] as String,
        startDate: b['start_date'] == null ? null : fromMs(b['start_date'] as int),
        weekCount: b['week_count'] as int,
        position: b['position'] as int,
      );
      final days = await db.query('program_days', where: 'block_id = ?', whereArgs: [block.id], orderBy: 'position');
      for (final d in days) {
        final day = ProgramDay(
          id: d['id'] as String,
          name: d['name'] as String,
          weekday: d['weekday'] as int,
          tag: (d['tag'] as String?) ?? '',
          position: d['position'] as int,
        );
        final exs = await db.query('program_exercises', where: 'day_id = ?', whereArgs: [day.id], orderBy: 'position');
        for (final e in exs) {
          final pe = ProgramExercise(
              id: e['id'] as String, exerciseId: e['exercise_id'] as String, position: e['position'] as int);
          final sets = await db.query('program_sets',
              where: 'program_exercise_id = ?', whereArgs: [pe.id], orderBy: 'week_index, position');
          pe.sets = sets.map(PrescribedSet.fromMap).toList();
          day.exercises.add(pe);
        }
        block.days.add(day);
      }
      program.blocks.add(block);
    }
    return program;
  }

  Future<void> save(Program p) async {
    final db = await _app.db;
    await db.transaction((txn) async {
      await _deleteChildren(txn, p.id);
      await txn.insert(
        'programs',
        {
          'id': p.id,
          'name': p.name,
          'description': p.description,
          'is_sample': p.isSample ? 1 : 0,
          'updated_at': nowMs()
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      for (var bi = 0; bi < p.blocks.length; bi++) {
        final b = p.blocks[bi];
        await txn.insert('program_blocks', {
          'id': b.id,
          'program_id': p.id,
          'name': b.name,
          'start_date': b.startDate?.millisecondsSinceEpoch,
          'week_count': b.weekCount,
          'position': bi,
        });
        for (var di = 0; di < b.days.length; di++) {
          final d = b.days[di];
          await txn.insert('program_days', {
            'id': d.id,
            'block_id': b.id,
            'name': d.name,
            'weekday': d.weekday,
            'tag': d.tag,
            'position': di,
          });
          for (var ei = 0; ei < d.exercises.length; ei++) {
            final e = d.exercises[ei];
            await txn
                .insert('program_exercises', {'id': e.id, 'day_id': d.id, 'exercise_id': e.exerciseId, 'position': ei});
            for (final s in e.sets) {
              await txn.insert('program_sets', s.toMap(e.id));
            }
          }
        }
      }
      await enqueue(txn, 'program', p.id);
    });
  }

  Future<void> _deleteChildren(Transaction txn, String programId) async {
    await txn.delete('program_sets',
        where: '''program_exercise_id IN (SELECT pe.id FROM program_exercises pe
          JOIN program_days d ON d.id = pe.day_id JOIN program_blocks b ON b.id = d.block_id WHERE b.program_id = ?)''',
        whereArgs: [programId]);
    await txn.delete('program_exercises',
        where:
            'day_id IN (SELECT d.id FROM program_days d JOIN program_blocks b ON b.id = d.block_id WHERE b.program_id = ?)',
        whereArgs: [programId]);
    await txn.delete('program_days',
        where: 'block_id IN (SELECT id FROM program_blocks WHERE program_id = ?)', whereArgs: [programId]);
    await txn.delete('program_blocks', where: 'program_id = ?', whereArgs: [programId]);
  }

  Future<void> delete(String id) async {
    final db = await _app.db;
    await db.transaction((txn) async {
      await _deleteChildren(txn, id);
      await txn.delete('programs', where: 'id = ?', whereArgs: [id]);
      await enqueue(txn, 'program', id, 'delete');
    });
  }

  /// Deep copy with fresh ids.
  Program duplicate(Program src) {
    return Program(
      name: '${src.name} (copy)',
      description: src.description,
      blocks: [for (final b in src.blocks) duplicateBlock(b, keepName: true)],
    );
  }

  ProgramBlock duplicateBlock(ProgramBlock b, {bool keepName = false, DateTime? start}) {
    return ProgramBlock(
      name: keepName ? b.name : '${b.name} (copy)',
      startDate: start,
      weekCount: b.weekCount,
      days: [
        for (final d in b.days)
          ProgramDay(name: d.name, weekday: d.weekday, tag: d.tag, exercises: [
            for (final e in d.exercises)
              ProgramExercise(exerciseId: e.exerciseId, sets: [
                for (final s in e.sets) s.copyForWeek(s.weekIndex),
              ]),
          ]),
      ],
    );
  }
}
