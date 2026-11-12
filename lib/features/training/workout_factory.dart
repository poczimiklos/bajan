import '../../data/models.dart';
import '../../data/repositories/exercise_repository.dart';
import '../../data/repositories/workout_repository.dart';

double _round25(double v) => (v / 2.5).round() * 2.5;

/// Turns a program day (for a given week) into a ready-to-log workout.
class WorkoutFactory {
  final ExerciseRepository exercises;
  final WorkoutRepository workouts;
  WorkoutFactory(this.exercises, this.workouts);

  /// [trainingMax] returns the kg value used for %-prescriptions of a lift.
  Future<Workout> fromDay({
    required Program program,
    required ProgramBlock block,
    required ProgramDay day,
    required int week,
    required double? Function(String lift) trainingMax,
    DateTime? date,
  }) async {
    final exMap = await exercises.map();
    final w = Workout(
      name: day.name,
      date: date ?? DateTime.now(),
      tag: day.tag,
      programBlockId: block.id,
      notes: '',
    );
    for (final pe in day.exercises) {
      final prescribed = pe.forWeek(week);
      final ex = exMap[pe.exerciseId];
      if (prescribed.isEmpty || ex == null) continue;
      final last = await workouts.lastPerformance(ex.id);
      final double? lastTop =
          last.isEmpty ? null : last.map((s) => (s.weight ?? 0).toDouble()).reduce((a, b) => a > b ? a : b);
      final we = WorkoutExercise(exercise: ex);
      var idx = 0;
      for (final ps in prescribed) {
        if (ps.tempo.isNotEmpty && we.tempo.isEmpty) we.tempo = ps.tempo;
        for (var i = 0; i < ps.sets; i++) {
          double? target;
          switch (ps.loadType) {
            case LoadType.abs:
              target = ps.weight;
            case LoadType.pct:
              final tm = ex.lift == null ? null : trainingMax(ex.lift!);
              if (tm != null && ps.weight != null) target = _round25(tm * ps.weight! / 100);
            case LoadType.linear:
              if (lastTop != null && lastTop > 0) target = lastTop + (ps.weight ?? 0);
          }
          // Free / RPE / max prescriptions: suggest the previous weight.
          final suggested = target ?? (idx < last.length ? last[idx].weight : lastTop);
          final label = [
            ps.loadText,
            if (ps.note.isNotEmpty) ps.note,
          ].where((e) => e.isNotEmpty).join(' · ');
          we.sets.add(SetEntry(
            type: ps.amrap && i == ps.sets - 1 ? SetType.amrap : SetType.working,
            prescText: label,
            prescReps: ps.repsMin,
            prescWeight: target,
            targetRpe: ps.rpeMax,
            weight: suggested,
            reps: ps.repsMin,
          ));
          idx++;
        }
      }
      if (we.sets.isNotEmpty) w.exercises.add(we);
    }
    return w;
  }
}
