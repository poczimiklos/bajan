import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/models.dart';
import '../../domain/stats.dart';
import '../../providers/providers.dart';
import '../training/start_workout.dart';
import 'widgets/e1rm_stats.dart';
import 'widgets/plan_card.dart';
import 'widgets/recent_records.dart';
import 'widgets/week_stats.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final stats = ref.watch(statsProvider);
    final plan = ref.watch(activePlanProvider);
    final records = ref.watch(recordsProvider).value ?? const <PersonalRecord>[];
    final bw = ref.watch(bodyweightProvider).value ?? const <BodyweightEntry>[];
    final active = ref.watch(workoutEditorProvider);

    return AsyncView<StatsCalc>(
      value: stats,
      onRetry: () => ref.invalidate(setRecordsProvider),
      data: (calc) {
        final now = DateTime.now();

        return ListView(padding: const EdgeInsets.all(16), children: [
          Text(DateFormat('EEEE, d MMMM').format(now), style: TextStyle(color: context.muted)),
          const SizedBox(height: 2),
          Text('Üdv újra, ${settings.username}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          PlanCard(plan: plan.value, loading: plan.isLoading),
          const SizedBox(height: 12),
          if (active != null && active.status == 'active')
            FilledButton.icon(
              icon: const Icon(Icons.play_arrow_rounded),
              onPressed: () => context.push('/workout'),
              label: const Text('Edzés folytatása'),
            )
          else
            FilledButton.icon(
              icon: const Icon(Icons.bolt),
              onPressed: () => StartWorkout.empty(context, ref),
              label: const Text('Gyors edzésindítás'),
            ),
          const SectionTitle('Ez a hét'),
          WeekStats(calc: calc, settings: settings),
          const SectionTitle('Becsült 1RM'),
          E1rmStats(calc: calc, settings: settings, bodyweight: bw),
          SectionTitle('Legújabb rekordok',
              trailing: TextButton(onPressed: () => context.push('/records'), child: const Text('Mind'))),
          RecentRecords(records: records, settings: settings),
          const SizedBox(height: 24),
        ]);
      },
    );
  }
}
