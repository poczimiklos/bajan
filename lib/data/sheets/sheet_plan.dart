/// A Google Sheets Apps Script által küldött terv JSON-ja (lásd Parser.gs).
int _int(Object? v, [int def = 0]) => v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? def;
String _str(Object? v) => v == null ? '' : '$v'.trim();

class SheetCell {
  final int week; // 0-alapú
  final String name, sets, reps, load, note;
  const SheetCell({
    required this.week,
    required this.name,
    this.sets = '',
    this.reps = '',
    this.load = '',
    this.note = '',
  });
  factory SheetCell.fromJson(Map<String, dynamic> j) => SheetCell(
        week: _int(j['week']),
        name: _str(j['name']),
        sets: _str(j['sets']),
        reps: _str(j['reps']),
        load: _str(j['load']),
        note: _str(j['note']),
      );
}

class SheetLine {
  final int row;
  final List<SheetCell> cells;
  const SheetLine(this.row, this.cells);
  factory SheetLine.fromJson(Map<String, dynamic> j) => SheetLine(
        _int(j['row']),
        [for (final c in (j['cells'] as List? ?? const [])) SheetCell.fromJson(Map<String, dynamic>.from(c as Map))],
      );
  SheetCell? cell(int week) {
    for (final c in cells) {
      if (c.week == week) return c;
    }
    return null;
  }
}

class SheetDay {
  final String name;
  final int weekday; // 1 = hétfő … 7 = vasárnap
  final List<SheetLine> lines;
  const SheetDay(this.name, this.weekday, this.lines);
  factory SheetDay.fromJson(Map<String, dynamic> j) => SheetDay(
        _str(j['name']),
        _int(j['weekday'], DateTime.monday),
        [for (final l in (j['lines'] as List? ?? const [])) SheetLine.fromJson(Map<String, dynamic>.from(l as Map))],
      );
}

class SheetPlan {
  final String sheet; // pl. "Block-1"
  final int weeks;
  final DateTime? startDate;
  final List<SheetDay> days;
  final String hash;
  const SheetPlan({required this.sheet, required this.weeks, this.startDate, required this.days, this.hash = ''});

  factory SheetPlan.fromJson(Map<String, dynamic> j) {
    final sd = _str(j['startDate']);
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(sd);
    return SheetPlan(
      sheet: _str(j['sheet']),
      weeks: _int(j['weeks'], 1),
      startDate: m == null ? null : DateTime(int.parse(m.group(1)!), int.parse(m.group(2)!), int.parse(m.group(3)!)),
      days: [for (final d in (j['days'] as List? ?? const [])) SheetDay.fromJson(Map<String, dynamic>.from(d as Map))],
      hash: _str(j['hash']),
    );
  }
}

class SheetPlans {
  final String title;
  final List<SheetPlan> plans;
  const SheetPlans(this.title, this.plans);
  factory SheetPlans.fromJson(Map<String, dynamic> j) => SheetPlans(
        _str(j['title']),
        [for (final p in (j['plans'] as List? ?? const [])) SheetPlan.fromJson(Map<String, dynamic>.from(p as Map))],
      );
}
