import '../../domain/e1rm.dart';
import '../checkin.dart';
import '../models.dart';

/// Hányadik hét a blokkban (1-alapú); a blokk előtti dátumra null.
int? weekNumber(DateTime? start, DateTime date) {
  if (start == null) return null;
  final a = DateTime.utc(start.year, start.month, start.day);
  final b = DateTime.utc(date.year, date.month, date.day);
  final d = b.difference(a).inDays;
  return d < 0 ? null : d ~/ 7 + 1;
}

double? _round(double? v, [int dp = 1]) {
  if (v == null) return null;
  final f = [1, 10, 100][dp];
  return (v * f).round() / f;
}

class WorkoutExport {
  final Map<String, Object?> workout;
  final List<Map<String, Object?>> sets;
  const WorkoutExport(this.workout, this.sets);
}

/// Egy kész edzés → a Napló / Edzések fül sorai. Csak a kipipált szettek kerülnek bele.
WorkoutExport exportWorkout(Workout w, {required String block, int? week, required E1rmFormula formula}) {
  final sets = <Map<String, Object?>>[];
  var volume = 0.0;
  for (final we in w.exercises) {
    final name = we.exercise.nameHu.isNotEmpty ? we.exercise.nameHu : we.exercise.name;
    var n = 0;
    for (final s in we.sets) {
      if (!s.completed) continue;
      n++;
      final e1 = (s.weight != null && s.reps != null && s.type != SetType.warmup)
          ? estimate1RM(weight: s.weight!, reps: s.reps!, rpe: s.rpe, formula: formula)
          : null;
      if (s.type != SetType.warmup && s.weight != null && s.reps != null) volume += s.weight! * s.reps!;
      final note = [if (n == 1) we.notes.trim(), s.note.trim()].where((e) => e.isNotEmpty).join(' · ');
      sets.add({
        'id': s.id,
        'workoutId': w.id,
        'date': dayKey(w.date),
        'block': block,
        'week': week,
        'day': w.name,
        'exercise': name,
        'set': n,
        'type': SetType.label(s.type),
        'targetReps': s.prescReps,
        'target': s.prescText,
        'weight': s.weight,
        'reps': s.reps,
        'rpe': s.rpe,
        'e1rm': _round(e1),
        'note': note,
      });
    }
  }
  final minutes = w.endedAt == null ? null : w.endedAt!.difference(w.startedAt).inMinutes;
  return WorkoutExport({
    'id': w.id,
    'date': dayKey(w.date),
    'block': block,
    'week': week,
    'day': w.name,
    'name': w.name,
    'startedAt': w.startedAt.toUtc().toIso8601String(),
    'endedAt': w.endedAt?.toUtc().toIso8601String(),
    'minutes': minutes,
    'volume': volume.round(),
    'doneSets': sets.length,
    'notes': w.notes,
  }, sets);
}

Map<String, Object?> checkInRow(CheckIn c) => {
      'id': c.id,
      'date': c.id,
      'sleep': c.sleep,
      'fatigue': c.fatigue,
      'readiness': c.readiness,
      'caffeineMg': c.caffeineMg,
      'creatineG': c.creatineG,
      'note': c.note,
    };
