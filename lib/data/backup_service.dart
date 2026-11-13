import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'database.dart';

/// Excel export and JSON restore of the whole local database.
class BackupService {
  final AppDatabase _app;
  BackupService(this._app);

  /// Writes an Excel workbook containing each database table on its own sheet.
  Future<File> exportToFile() async {
    final db = await _app.db;
    final workbook = Excel.createExcel();
    final dir = await getTemporaryDirectory();
    final stamp = DateTime.now().toIso8601String().substring(0, 10);
    for (var i = 0; i < kTables.length; i++) {
      final table = kTables[i];
      final sheetName = table[0].toUpperCase() + table.substring(1);
      if (i == 0) {
        workbook.rename('Sheet1', sheetName);
      }
      final sheet = workbook[sheetName];
      final columns =
          (await db.rawQuery('PRAGMA table_info($table)')).map((column) => column['name'] as String).toList();
      sheet.appendRow([for (final column in columns) TextCellValue(column)]);
      final rows = await db.query(table);
      for (final row in rows) {
        sheet.appendRow([for (final column in columns) _cellValue(row[column])]);
      }
    }
    final bytes = workbook.save();
    if (bytes == null) throw StateError('Could not encode the Excel workbook');
    final file = File('${dir.path}/powerlifting_data_$stamp.xlsx');
    return file.writeAsBytes(bytes);
  }

  CellValue? _cellValue(Object? value) {
    if (value == null) return null;
    if (value is int) return IntCellValue(value);
    if (value is num) return DoubleCellValue(value.toDouble());
    if (value is bool) return BoolCellValue(value);
    return TextCellValue(value.toString());
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
