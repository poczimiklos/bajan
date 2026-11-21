import '../../../data/settings.dart';
import 'package:flutter/material.dart';
import '../../../core/widgets/common.dart';
import '../../../domain/stats.dart';

class SummaryGrid extends StatelessWidget {
  final StatsCalc calc;
  final AppSettings settings;
  final DateTime? from;
  const SummaryGrid({super.key, required this.calc, required this.settings, required this.from});

  @override
  Widget build(BuildContext context) {
    final avg = calc.avgRpe(from: from);
    final freq = calc.frequencyPerWeek(from: from);
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        mainAxisExtent: 92,
      ),
      children: [
        StatTile(label: 'Összes ismétlés', value: '${calc.totalReps(from: from)}'),
        StatTile(label: 'Átlagos RPE', value: avg == null ? '–' : fmtNum(avg)),
        StatTile(label: 'Edzés / hét', value: freq == null ? '–' : fmtNum(freq)),
        StatTile(
          label: 'Volumen',
          value: fmtNum(settings.toDisplay(calc.since(from).fold(0.0, (a, s) => a + s.weight * s.reps)), decimals: 0),
          unit: settings.unitLabel,
        ),
      ],
    );
  }
}
