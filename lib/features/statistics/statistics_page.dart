import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../domain/e1rm.dart';
import '../../domain/stats.dart';
import '../../providers/providers.dart';
import 'widgets/best_tile.dart';
import 'widgets/monthly_volume_list.dart';
import 'widgets/stats_filters.dart';
import 'widgets/summary_grid.dart';
import 'widgets/line_chart_card.dart';
import 'widgets/bar_chart_card.dart';

class StatisticsPage extends ConsumerStatefulWidget {
  const StatisticsPage({super.key});
  @override
  ConsumerState<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends ConsumerState<StatisticsPage> {
  int _range = 2; // 90D
  String _lift = 'total'; // squat | bench | deadlift | total

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final stats = ref.watch(statsProvider);
    return AsyncView<StatsCalc>(
      value: stats,
      onRetry: () => ref.invalidate(setRecordsProvider),
      data: (calc) {
        final days = statsRanges[_range].$2;
        final from = days == null ? null : DateTime.now().subtract(Duration(days: days));
        if (calc.all.isEmpty) {
          return const EmptyState(
            icon: Icons.show_chart,
            title: 'No data yet',
            message: 'Finish a workout with completed sets and your analytics will appear here.',
          );
        }
        final series = _lift == 'total' ? calc.totalSeries(from: from) : calc.e1rmSeries(_lift, from: from);
        final weekly = calc.weeklyVolume(from: from);
        final monthly = calc.monthlyVolume(from: from);
        final liftArg = _lift == 'total' ? null : _lift;
        final bests = calc.bests(from: from, lift: liftArg);

        return ListView(padding: const EdgeInsets.all(16), children: [
          const Text('Statistics', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          StatsFilters(
            range: _range,
            lift: _lift,
            onRange: (i) => setState(() => _range = i),
            onLift: (l) => setState(() => _lift = l),
          ),
          SectionTitle('Estimated 1RM · ${settings.formula.label}'),
          AppCard(
            padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
            child: SizedBox(height: 220, child: LineChartCard(points: series, settings: settings)),
          ),
          const SectionTitle('Summary'),
          SummaryGrid(calc: calc, settings: settings, from: from),
          const SectionTitle('Weekly volume'),
          AppCard(
            padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
            child: SizedBox(
                height: 180, child: BarChartCard(points: weekly, settings: settings, labelFmt: DateFormat('d MMM'))),
          ),
          const SectionTitle('Monthly volume'),
          MonthlyVolumeList(points: monthly, settings: settings),
          SectionTitle('Records in range',
              trailing: TextButton(onPressed: () => context.push('/records'), child: const Text('All records'))),
          BestTile('Heaviest weight', bests.heaviest, settings, (s) => fmtNum(settings.toDisplay(s.weight))),
          BestTile('Best e1RM', bests.bestE1rm, settings, (s) => fmtNum(settings.toDisplay(calc.e1rm(s) ?? 0))),
          BestTile('Best rep set', bests.mostReps, settings, (s) => '${s.reps} reps'),
          if (calc.bestActualTotal() != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(children: [
                  const Expanded(
                      child: Text('Highest SBD total (actual)', style: TextStyle(fontWeight: FontWeight.w700))),
                  Text('${fmtNum(settings.toDisplay(calc.bestActualTotal()!))} ${settings.unitLabel}',
                      style: TextStyle(color: context.accent, fontWeight: FontWeight.w800)),
                ]),
              ),
            ),
          const SizedBox(height: 24),
        ]);
      },
    );
  }
}
