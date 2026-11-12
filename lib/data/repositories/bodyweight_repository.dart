import 'package:sqflite/sqflite.dart';
import '../database.dart';
import '../models.dart';

class BodyweightRepository {
  final AppDatabase _app;
  BodyweightRepository(this._app);

  Future<List<BodyweightEntry>> all() async {
    final db = await _app.db;
    final rows = await db.query('bodyweight', orderBy: 'date DESC');
    return rows.map(BodyweightEntry.fromMap).toList();
  }

  Future<void> add(BodyweightEntry e) async {
    final db = await _app.db;
    await db.transaction((txn) async {
      await txn.insert('bodyweight', e.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      await enqueue(txn, 'bodyweight', e.id);
    });
  }

  Future<void> delete(String id) async {
    final db = await _app.db;
    await db.delete('bodyweight', where: 'id = ?', whereArgs: [id]);
    await enqueue(db, 'bodyweight', id, 'delete');
  }
}
