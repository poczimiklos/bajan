import '../../data/models.dart';

/// Where "today" sits inside the active block.
class ActivePlan {
  final Program program;
  final ProgramBlock block;
  final int week; // 0-based, clamped
  final bool notStarted;
  final bool finished;
  final ProgramDay? today; // a day scheduled for today (with work)
  final ProgramDay? next; // next scheduled day
  final DateTime? nextDate;
  final int nextWeek;

  const ActivePlan({
    required this.program,
    required this.block,
    required this.week,
    required this.notStarted,
    required this.finished,
    this.today,
    this.next,
    this.nextDate,
    this.nextWeek = 0,
  });

  String get weekLabel => 'Week ${week + 1} of ${block.weekCount}';

  static ActivePlan? compute(Program program, ProgramBlock block, DateTime now) {
    final start = block.startDate;
    if (start == null) return null;
    final today = DateTime(now.year, now.month, now.day);
    final s = DateTime(start.year, start.month, start.day);
    final diff = today.difference(s).inDays;
    final notStarted = diff < 0;
    final finished = diff >= block.weekCount * 7;
    final week = (diff ~/ 7).clamp(0, block.weekCount - 1);

    ProgramDay? todayDay;
    for (final d in block.days) {
      if (d.weekday == today.weekday && d.hasWork(week)) todayDay = d;
    }
    ProgramDay? next;
    DateTime? nextDate;
    var nextWeek = week;
    if (!finished) {
      for (var i = 1; i <= block.weekCount * 7 && next == null; i++) {
        final dt = today.add(Duration(days: i));
        final off = dt.difference(s).inDays;
        if (off < 0) continue;
        if (off >= block.weekCount * 7) break;
        final w = off ~/ 7;
        for (final d in block.days) {
          if (d.weekday == dt.weekday && d.hasWork(w)) {
            next = d;
            nextDate = dt;
            nextWeek = w;
          }
        }
      }
    }
    return ActivePlan(
      program: program,
      block: block,
      week: week,
      notStarted: notStarted,
      finished: finished,
      today: notStarted || finished ? null : todayDay,
      next: next,
      nextDate: nextDate,
      nextWeek: nextWeek,
    );
  }
}
