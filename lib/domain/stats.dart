import '../data/models.dart';
import 'e1rm.dart';

class DatedValue {
  final DateTime date;
  final double value;
  const DatedValue(this.date, this.value);
}

DateTime weekStart(DateTime d) {
  final day = DateTime(d.year, d.month, d.day);
  return day.subtract(Duration(days: day.weekday - 1));
}

/// Pure statistics over completed sets. No Flutter / DB dependencies.
class StatsCalc {
  final List<SetRecord> all;
  final E1rmFormula formula;
  StatsCalc(List<SetRecord> sets, this.formula) : all = sets;

  bool _counts(SetRecord s) => s.setType != SetType.warmup;

  double? e1rm(SetRecord s) => estimate1RM(weight: s.weight, reps: s.reps, rpe: s.rpe, formula: formula);

  List<SetRecord> since(DateTime? from) =>
      all.where((s) => _counts(s) && (from == null || !s.date.isBefore(from))).toList();

  Iterable<SetRecord> _mainSets(String lift) => all.where((s) => _counts(s) && s.lift == lift && !s.variation);

  /// Best e1RM per training day for a lift (competition-style exercises only).
  List<DatedValue> e1rmSeries(String lift, {DateTime? from}) {
    final byDay = <DateTime, double>{};
    for (final s in _mainSets(lift)) {
      final e = e1rm(s);
      if (e == null) continue;
      final d = DateTime(s.date.year, s.date.month, s.date.day);
      if (e > (byDay[d] ?? 0)) byDay[d] = e;
    }
    final keys = byDay.keys.toList()..sort();
    return [
      for (final k in keys)
        if (from == null || !k.isBefore(from)) DatedValue(k, byDay[k]!)
    ];
  }

  /// Sum of the best known e1RM per lift, carried forward over time.
  List<DatedValue> totalSeries({DateTime? from}) {
    final events = <DateTime, Map<String, double>>{};
    for (final lift in Lift.all) {
      for (final p in e1rmSeries(lift)) {
        (events[p.date] ??= {})[lift] = p.value;
      }
    }
    final dates = events.keys.toList()..sort();
    final best = <String, double>{};
    final out = <DatedValue>[];
    for (final d in dates) {
      events[d]!.forEach((l, v) {
        if (v > (best[l] ?? 0)) best[l] = v;
      });
      if (best.length == 3 && (from == null || !d.isBefore(from))) {
        out.add(DatedValue(d, best.values.fold(0.0, (a, b) => a + b)));
      }
    }
    return out;
  }

  /// Current e1RM: best within the last [days] days, else all-time best.
  double? currentE1rm(String lift, {int days = 60}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    double? recent, allTime;
    for (final s in _mainSets(lift)) {
      final e = e1rm(s);
      if (e == null) continue;
      if (e > (allTime ?? 0)) allTime = e;
      if (!s.date.isBefore(cutoff) && e > (recent ?? 0)) recent = e;
    }
    return recent ?? allTime;
  }

  double? currentTotal() {
    final v = Lift.all.map(currentE1rm).toList();
    if (v.any((e) => e == null)) return null;
    return v.fold<double>(0, (a, b) => a + b!);
  }

  /// Heaviest actual weight lifted per lift, summed (competition-style lifts).
  double? bestActualTotal() {
    double total = 0;
    for (final lift in Lift.all) {
      double best = 0;
      for (final s in _mainSets(lift)) {
        if (s.weight > best) best = s.weight;
      }
      if (best == 0) return null;
      total += best;
    }
    return total;
  }

  /// Volume (kg) per week, oldest first.
  List<DatedValue> weeklyVolume({DateTime? from}) {
    final m = <DateTime, double>{};
    for (final s in since(from)) {
      final k = weekStart(s.date);
      m[k] = (m[k] ?? 0) + s.weight * s.reps;
    }
    final keys = m.keys.toList()..sort();
    return [for (final k in keys) DatedValue(k, m[k]!)];
  }

  List<DatedValue> monthlyVolume({DateTime? from}) {
    final m = <DateTime, double>{};
    for (final s in since(from)) {
      final k = DateTime(s.date.year, s.date.month);
      m[k] = (m[k] ?? 0) + s.weight * s.reps;
    }
    final keys = m.keys.toList()..sort();
    return [for (final k in keys) DatedValue(k, m[k]!)];
  }

  int totalReps({DateTime? from}) => since(from).fold(0, (a, s) => a + s.reps);

  double? avgRpe({DateTime? from}) {
    final r = since(from).where((s) => s.rpe != null && s.rpe! > 0).toList();
    if (r.isEmpty) return null;
    return r.fold(0.0, (a, s) => a + s.rpe!) / r.length;
  }

  int workoutCount({DateTime? from}) => since(from).map((s) => s.workoutId).toSet().length;

  /// Average workouts per week over the window.
  double? frequencyPerWeek({DateTime? from}) {
    final sets = since(from);
    if (sets.isEmpty) return null;
    final start = from ?? sets.map((s) => s.date).reduce((a, b) => a.isBefore(b) ? a : b);
    final weeks = (DateTime.now().difference(start).inDays / 7).clamp(1, 100000).toDouble();
    return workoutCount(from: from) / weeks;
  }

  double volumeBetween(DateTime from, DateTime to) => all
      .where((s) => _counts(s) && !s.date.isBefore(from) && s.date.isBefore(to))
      .fold(0.0, (a, s) => a + s.weight * s.reps);

  /// Consecutive weeks (ending this or last week) with at least one workout.
  int weekStreak() {
    final weeks = all.map((s) => weekStart(s.date)).toSet();
    var cursor = weekStart(DateTime.now());
    if (!weeks.contains(cursor)) cursor = cursor.subtract(const Duration(days: 7));
    var n = 0;
    while (weeks.contains(cursor)) {
      n++;
      cursor = cursor.subtract(const Duration(days: 7));
    }
    return n;
  }

  /// Best (heaviest weight, best e1RM, most reps) within the window.
  ({SetRecord? heaviest, SetRecord? bestE1rm, SetRecord? mostReps}) bests({DateTime? from, String? lift}) {
    SetRecord? h, e, r;
    double bestE = 0;
    for (final s in since(from)) {
      if (lift != null && (s.lift != lift || s.variation)) continue;
      if (h == null || s.weight > h.weight) h = s;
      if (r == null || s.reps > r.reps) r = s;
      final v = e1rm(s) ?? 0;
      if (v > bestE) {
        bestE = v;
        e = s;
      }
    }
    return (heaviest: h, bestE1rm: e, mostReps: r);
  }
}
