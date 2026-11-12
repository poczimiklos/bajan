import 'package:flutter/material.dart';
import '../../../core/widgets/common.dart';
import '../../../domain/stats.dart';

import '../../../data/settings.dart';

class WeekStats extends StatelessWidget {
  final StatsCalc calc;
  final AppSettings settings;
  const WeekStats({super.key, required this.calc, required this.settings});

  @override
  Widget build(BuildContext context) {
    final ws = weekStart(DateTime.now());
    final weekVol = calc.volumeBetween(ws, ws.add(const Duration(days: 7)));
    final weekWorkouts = calc.workoutCount(from: ws);
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        mainAxisExtent: 96,
      ),
      children: [
        StatTile(
            label: 'Volume',
            value: fmtNum(settings.toDisplay(weekVol), decimals: 0),
            unit: settings.unitLabel,
            icon: Icons.scale),
        StatTile(label: 'Workouts', value: '$weekWorkouts', icon: Icons.fitness_center),
        StatTile(label: 'Streak', value: '${calc.weekStreak()}', unit: 'wk', icon: Icons.local_fire_department),
      ],
    );
  }
}
