import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'database.dart';

/// JSON export / restore of the whole local database.
class BackupService {
  final AppDatabase _app;
  BackupService(this._app);

  Future<Map<String, Object?>> _dump() async {
    final db = await _app.db;
    final data = <String, Object?>{};
    for (final t in kTables) {
      data[t] = await db.query(t);
    }
    return {
      'app': 'powerlifting_tracker',
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'tables': data
    };
  }

  /// Writes a backup file and returns it (share it from the UI).
  Future<File> exportToFile() async {
    final dir = await getTemporaryDirectory();
    final stamp = DateTime.now().toIso8601String().substring(0, 10);
    final f = File('${dir.path}/powerlifting_backup_$stamp.json');
    return f.writeAsString(const JsonEncoder.withIndent(' ').convert(await _dump()));
  }

  /// Replaces ALL local data with the content of a backup file.
  Future<void> restoreFromJson(String json) async {
    final decoded = jsonDecode(json);
    if (decoded is! Map || decoded['app'] != 'powerlifting_tracker' || decoded['tables'] is! Map) {
      throw const FormatException('Not a valid backup file');
    }
    final tables = decoded['tables'] as Map;
    final db = await _app.db;
    await db.transaction((txn) async {
      for (final t in kTables.reversed) {
        await txn.delete(t);
      }
      for (final t in kTables) {
        final rows = (tables[t] as List?) ?? const [];
        for (final r in rows) {
          await txn.insert(t, Map<String, Object?>.from(r as Map), conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
    });
  }
}
