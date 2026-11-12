import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/common.dart';
import '../../data/models.dart';
import '../../providers/providers.dart';
import 'start_workout.dart';
import 'widgets/history_tile.dart';

class TrainingPage extends ConsumerWidget {
  const TrainingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);
    final plan = ref.watch(activePlanProvider).value;
    final settings = ref.watch(settingsProvider);
    final active = ref.watch(workoutEditorProvider);

    return AsyncView<List<Workout>>(
      value: history,
      onRetry: () => ref.invalidate(historyProvider),
      data: (list) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Training', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          if (active != null && active.status == 'active')
            FilledButton.icon(
              icon: const Icon(Icons.play_arrow_rounded),
              onPressed: () => context.push('/workout'),
              label: Text('Resume · ${active.name}'),
            )
          else
            FilledButton.icon(
              icon: const Icon(Icons.add),
              onPressed: () => StartWorkout.empty(context, ref),
              label: const Text('Start empty workout'),
            ),
          if (plan != null && plan.today != null) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              icon: const Icon(Icons.event_available),
              onPressed: () => StartWorkout.fromPlan(context, ref, plan),
              label: Text('Start today: ${plan.today!.name} (${plan.weekLabel})'),
            ),
          ],
          const SectionTitle('History'),
          if (list.isEmpty)
            const SizedBox(
              height: 260,
              child: EmptyState(
                icon: Icons.fitness_center,
                title: 'No workouts yet',
                message: 'Your finished workouts will appear here. Start one above.',
              ),
            )
          else
            for (final w in list) HistoryTile(workout: w, unit: settings.unitLabel, toDisplay: settings.toDisplay),
        ],
      ),
    );
  }
}
