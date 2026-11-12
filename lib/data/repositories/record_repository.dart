import 'package:sqflite/sqflite.dart';
import '../../domain/e1rm.dart';
import '../database.dart';
import '../models.dart';

class RecordRepository {
  final AppDatabase _app;
  RecordRepository(this._app);

  Future<List<PersonalRecord>> all() async {
    final db = await _app.db;
    final rows = await db.query('personal_records', orderBy: 'date DESC');
    return rows.map(PersonalRecord.fromMap).toList();
  }

  Future<double?> _best(DatabaseExecutor ex, String exerciseId, String kind, {double? weight}) async {
    final rows = await ex.rawQuery(
      'SELECT MAX(value) AS v FROM personal_records WHERE exercise_id = ? AND kind = ?'
      '${weight != null ? ' AND weight = ?' : ''}',
      [exerciseId, kind, if (weight != null) weight],
    );
    return (rows.first['v'] as num?)?.toDouble();
  }

  /// Compares the completed sets of [w] with stored records, stores new PRs
  /// and returns them. Re-running for the same workout is safe: its previous
  /// records are removed first.
  Future<List<PersonalRecord>> detectAndStore(Workout w, E1rmFormula formula) async {
    final db = await _app.db;
    final created = <PersonalRecord>[];
    await db.transaction((txn) async {
      await txn.delete('personal_records', where: 'workout_id = ?', whereArgs: [w.id]);
      for (final we in w.exercises) {
        final sets = we.sets
            .where((s) => s.completed && s.type != SetType.warmup && (s.weight ?? 0) > 0 && (s.reps ?? 0) > 0)
            .toList();
        if (sets.isEmpty) continue;

        Future<void> add(String kind, double value, SetEntry s, {double? weight}) async {
          final prev = await _best(txn, we.exercise.id, kind, weight: weight);
          if (prev != null && value <= prev + 1e-9) return;
          final rec = PersonalRecord(
            id: newId(),
            exerciseId: we.exercise.id,
            exerciseName: we.exercise.name,
            kind: kind,
            value: value,
            previous: prev,
            reps: s.reps,
            weight: s.weight,
            date: w.date,
            workoutId: w.id,
          );
          await txn.insert('personal_records', rec.toMap());
          await enqueue(txn, 'record', rec.id);
          created.add(rec);
        }

        // Heaviest weight.
        final heaviest = sets.reduce((a, b) => (a.weight ?? 0) >= (b.weight ?? 0) ? a : b);
        await add('weight', heaviest.weight!, heaviest);

        // Best e1RM.
        SetEntry? bestSet;
        double bestE = 0;
        for (final s in sets) {
          final e = estimate1RM(weight: s.weight!, reps: s.reps!, rpe: s.rpe, formula: formula) ?? 0;
          if (e > bestE) {
            bestE = e;
            bestSet = s;
          }
        }
        if (bestSet != null) await add('e1rm', double.parse(bestE.toStringAsFixed(1)), bestSet);

        // Rep records per weight (only meaningful once that weight was lifted before).
        final byWeight = <double, SetEntry>{};
        for (final s in sets) {
          final cur = byWeight[s.weight!];
          if (cur == null || s.reps! > cur.reps!) byWeight[s.weight!] = s;
        }
        for (final e in byWeight.entries) {
          final prev = await _best(txn, we.exercise.id, 'reps', weight: e.key);
          if (prev == null) {
            // First time at this weight: store baseline silently (previous = null).
            final rec = PersonalRecord(
              id: newId(),
              exerciseId: we.exercise.id,
              exerciseName: we.exercise.name,
              kind: 'reps',
              value: e.value.reps!.toDouble(),
              previous: null,
              reps: e.value.reps,
              weight: e.key,
              date: w.date,
              workoutId: w.id,
            );
            await txn.insert('personal_records', rec.toMap());
          } else {
            await add('reps', e.value.reps!.toDouble(), e.value, weight: e.key);
          }
        }
      }
    });
    // Only celebrate genuine improvements (not first baselines).
    return created.where((r) => r.previous != null).toList();
  }
}
