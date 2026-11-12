import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../data/models.dart';
import '../../../domain/scores.dart';
import '../../../domain/stats.dart';

import '../../../data/settings.dart';

class E1rmStats extends StatelessWidget {
  final StatsCalc calc;
  final AppSettings settings;
  final List<BodyweightEntry> bodyweight;
  const E1rmStats({super.key, required this.calc, required this.settings, required this.bodyweight});

  @override
  Widget build(BuildContext context) {
    final total = calc.currentTotal();
    final dots = (total != null && bodyweight.isNotEmpty)
        ? dotsScore(totalKg: total, bodyweightKg: bodyweight.first.kg, male: settings.sex == 'm')
        : null;
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
        for (final l in Lift.all)
          StatTile(
            label: Lift.label(l),
            value: calc.currentE1rm(l) == null ? '–' : fmtNum(settings.toDisplay(calc.currentE1rm(l)!)),
            unit: settings.unitLabel,
          ),
        StatTile(
          label: 'SBD total${dots != null ? ' · DOTS ${fmtNum(dots)}' : ''}',
          value: total == null ? '–' : fmtNum(settings.toDisplay(total)),
          unit: settings.unitLabel,
          valueColor: context.accent,
        ),
      ],
    );
  }
}
