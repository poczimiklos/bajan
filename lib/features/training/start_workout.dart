import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/common.dart';
import '../../data/models.dart';
import '../../providers/providers.dart';
import 'plan.dart';
import 'workout_factory.dart';

/// Shared "start" actions used by Dashboard, Training and Programs.
class StartWorkout {
  /// Starts an empty workout (asks before replacing an unfinished one).
  static Future<void> empty(BuildContext context, WidgetRef ref) async {
    if (!await _canReplace(context, ref)) return;
    await ref.read(workoutEditorProvider.notifier).startEmpty();
    if (context.mounted) context.push('/workout');
  }

  static Future<void> fromDay(
    BuildContext context,
    WidgetRef ref, {
    required Program program,
    required ProgramBlock block,
    required ProgramDay day,
    required int week,
  }) async {
    if (!await _canReplace(context, ref)) return;
    final settings = ref.read(settingsProvider);
    final calc = ref.read(statsProvider).value;
    double? tm(String lift) {
      final v = settings.trainingMax[lift] ?? 0;
      if (v > 0) return v;
      final e = calc?.currentE1rm(lift);
      return e == null ? null : e * 0.9;
    }

    final w = await WorkoutFactory(ref.read(exerciseRepoProvider), ref.read(workoutRepoProvider))
        .fromDay(program: program, block: block, day: day, week: week, trainingMax: tm);
    if (w.exercises.isEmpty) {
      if (context.mounted) snack(context, 'This day has nothing prescribed for week ${week + 1}.');
      return;
    }
    await ref.read(workoutEditorProvider.notifier).start(w);
    if (context.mounted) context.push('/workout');
  }

  static Future<void> fromPlan(BuildContext context, WidgetRef ref, ActivePlan plan, {bool useNext = false}) {
    final day = useNext ? plan.next! : plan.today!;
    return fromDay(context, ref,
        program: plan.program, block: plan.block, day: day, week: useNext ? plan.nextWeek : plan.week);
  }

  static Future<bool> _canReplace(BuildContext context, WidgetRef ref) async {
    final cur = ref.read(workoutEditorProvider);
    if (cur == null || cur.status != 'active') return true;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Workout in progress'),
        content: const Text('Finish or resume your current workout first. Starting a new one will discard it.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Keep current')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Discard & start new')),
        ],
      ),
    );
    if (ok != true) {
      if (context.mounted) context.push('/workout');
      return false;
    }
    await ref.read(workoutEditorProvider.notifier).discard();
    return true;
  }
}
