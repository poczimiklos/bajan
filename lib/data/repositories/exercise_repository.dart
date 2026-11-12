import 'package:sqflite/sqflite.dart';
import '../database.dart';
import '../models.dart';
import '../seed_exercises.dart';

class ExerciseRepository {
  final AppDatabase _app;
  ExerciseRepository(this._app);

  /// Inserts the built-in library once (existing ids are left untouched).
  Future<void> seedIfNeeded() async {
    final db = await _app.db;
    final batch = db.batch();
    for (final e in seedExercises) {
      batch.insert('exercises', e.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Exercise>> all({bool includeArchived = false}) async {
    final db = await _app.db;
    final rows = await db.query(
      'exercises',
      where: includeArchived ? 'deleted_at IS NULL' : 'deleted_at IS NULL AND archived = 0',
      orderBy: "category ASC, name COLLATE NOCASE ASC",
    );
    return rows.map(Exercise.fromMap).toList();
  }

  Future<Map<String, Exercise>> map() async {
    final list = await all(includeArchived: true);
    return {for (final e in list) e.id: e};
  }

  Future<void> save(Exercise e) async {
    final db = await _app.db;
    await db.transaction((txn) async {
      await txn.insert('exercises', e.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      await enqueue(txn, 'exercise', e.id);
    });
  }

  Future<void> archive(String id, bool archived) async {
    final db = await _app.db;
    await db.update('exercises', {'archived': archived ? 1 : 0, 'updated_at': nowMs()},
        where: 'id = ?', whereArgs: [id]);
    await enqueue(db, 'exercise', id);
  }
}
