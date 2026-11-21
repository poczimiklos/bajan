import 'package:sqflite/sqflite.dart';
import '../checkin.dart';
import '../database.dart';

class CheckInRepository {
  final AppDatabase _app;
  CheckInRepository(this._app);

  Future<CheckIn?> forDay(DateTime d) async {
    final db = await _app.db;
    final rows = await db.query('checkins', where: 'id = ?', whereArgs: [dayKey(d)], limit: 1);
    return rows.isEmpty ? null : CheckIn.fromMap(rows.first);
  }

  Future<List<CheckIn>> all() async {
    final db = await _app.db;
    final rows = await db.query('checkins', orderBy: 'date DESC');
    return rows.map(CheckIn.fromMap).toList();
  }

  Future<void> save(CheckIn c) async {
    final db = await _app.db;
    await db.transaction((txn) async {
      await txn.insert('checkins', c.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      await enqueue(txn, 'checkin', c.id);
    });
  }
}
