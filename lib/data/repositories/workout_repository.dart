import 'package:sqflite/sqflite.dart';
import '../database.dart';
import '../models.dart';
import 'exercise_repository.dart';

class WorkoutRepository {
  final AppDatabase _app;
  final ExerciseRepository _exercises;
  WorkoutRepository(this._app, this._exercises);

  /// Persists the whole workout atomically (parent + children).
  Future<void> save(Workout w) async {
    final db = await _app.db;
    await db.transaction((txn) async {
      await txn.insert('workouts', w.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      await txn.delete('workout_sets',
          where: 'workout_exercise_id IN (SELECT id FROM workout_exercises WHERE workout_id = ?)', whereArgs: [w.id]);
      await txn.delete('workout_exercises', where: 'workout_id = ?', whereArgs: [w.id]);
      for (var i = 0; i < w.exercises.length; i++) {
        final we = w.exercises[i];
        await txn.insert('workout_exercises', {
          'id': we.id,
          'workout_id': w.id,
          'exercise_id': we.exercise.id,
          'position': i,
          'notes': we.notes,
          'tempo': we.tempo,
        });
        for (var j = 0; j < we.sets.length; j++) {
          await txn.insert('workout_sets', we.sets[j].toMap(we.id, j));
        }
      }
      await enqueue(txn, 'workout', w.id);
    });
  }

  Future<void> delete(String id) async {
    final db = await _app.db;
    await db.transaction((txn) async {
      await txn.delete('workout_sets',
          where: 'workout_exercise_id IN (SELECT id FROM workout_exercises WHERE workout_id = ?)', whereArgs: [id]);
      await txn.delete('workout_exercises', where: 'workout_id = ?', whereArgs: [id]);
      await txn.delete('personal_records', where: 'workout_id = ?', whereArgs: [id]);
      await txn.delete('workouts', where: 'id = ?', whereArgs: [id]);
      await enqueue(txn, 'workout', id, 'delete');
    });
  }

  Future<Workout?> active() async {
    final db = await _app.db;
    final rows = await db.query('workouts',
        where: "status = 'active' AND deleted_at IS NULL", orderBy: 'started_at DESC', limit: 1);
    if (rows.isEmpty) return null;
    return _hydrate(rows.first, await _exercises.map());
  }

  Future<Workout?> load(String id) async {
    final db = await _app.db;
    final rows = await db.query('workouts', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return _hydrate(rows.first, await _exercises.map());
  }

  Future<List<Workout>> history({int limit = 300}) async {
    final db = await _app.db;
    final rows = await db.query('workouts',
        where: "status = 'done' AND deleted_at IS NULL", orderBy: 'date DESC, started_at DESC', limit: limit);
    final ex = await _exercises.map();
    final out = <Workout>[];
    for (final r in rows) {
      out.add(await _hydrate(r, ex));
    }
    return out;
  }

  Future<Workout> _hydrate(DbRow row, Map<String, Exercise> ex) async {
    final db = await _app.db;
    final w = Workout.fromMap(row);
    final wes = await db.query('workout_exercises', where: 'workout_id = ?', whereArgs: [w.id], orderBy: 'position');
    for (final we in wes) {
      final exercise = ex[we['exercise_id'] as String];
      if (exercise == null) continue;
      final sets =
          await db.query('workout_sets', where: 'workout_exercise_id = ?', whereArgs: [we['id']], orderBy: 'position');
      w.exercises.add(WorkoutExercise(
        id: we['id'] as String,
        exercise: exercise,
        notes: (we['notes'] as String?) ?? '',
        tempo: (we['tempo'] as String?) ?? '',
        sets: sets.map(SetEntry.fromMap).toList(),
      ));
    }
    return w;
  }

  /// Completed sets of the most recent finished workout containing [exerciseId].
  Future<List<SetEntry>> lastPerformance(String exerciseId, {String? excludeWorkoutId}) async {
    final db = await _app.db;
    final rows = await db.rawQuery('''
      SELECT we.id AS we_id FROM workout_exercises we
      JOIN workouts w ON w.id = we.workout_id
      WHERE we.exercise_id = ? AND w.status = 'done' AND w.deleted_at IS NULL
        AND (? IS NULL OR w.id != ?)
        AND EXISTS (SELECT 1 FROM workout_sets s WHERE s.workout_exercise_id = we.id AND s.completed = 1)
      ORDER BY w.date DESC, w.started_at DESC LIMIT 1''', [exerciseId, excludeWorkoutId, excludeWorkoutId]);
    if (rows.isEmpty) return [];
    final sets = await db.query('workout_sets',
        where: 'workout_exercise_id = ? AND completed = 1', whereArgs: [rows.first['we_id']], orderBy: 'position');
    return sets.map(SetEntry.fromMap).toList();
  }

  /// All completed sets (for statistics / PR detection).
  Future<List<SetRecord>> setRecords() async {
    final db = await _app.db;
    final rows = await db.rawQuery('''
      SELECT w.date AS date, w.id AS workout_id, e.id AS ex_id, e.name AS ex_name, e.lift AS lift,
             e.variation AS variation, s.set_type AS set_type, s.weight AS weight, s.reps AS reps, s.rpe AS rpe
      FROM workout_sets s
      JOIN workout_exercises we ON we.id = s.workout_exercise_id
      JOIN workouts w ON w.id = we.workout_id
      JOIN exercises e ON e.id = we.exercise_id
      WHERE s.completed = 1 AND w.status = 'done' AND w.deleted_at IS NULL
        AND s.weight IS NOT NULL AND s.reps IS NOT NULL
      ORDER BY w.date ASC''');
    return rows
        .map((r) => SetRecord(
              date: fromMs(r['date'] as int),
              workoutId: r['workout_id'] as String,
              exerciseId: r['ex_id'] as String,
              exerciseName: r['ex_name'] as String,
              lift: r['lift'] as String?,
              variation: (r['variation'] as int? ?? 0) == 1,
              setType: r['set_type'] as String,
              weight: (r['weight'] as num).toDouble(),
              reps: r['reps'] as int,
              rpe: (r['rpe'] as num?)?.toDouble(),
            ))
        .toList();
  }
}
