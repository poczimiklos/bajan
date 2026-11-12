import '../../../data/settings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/common.dart';
import '../../../domain/stats.dart';

class MonthlyVolumeList extends StatelessWidget {
  final List<DatedValue> points;
  final AppSettings settings;
  const MonthlyVolumeList({super.key, required this.points, required this.settings});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      for (final m in points.reversed.take(12))
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(children: [
              Expanded(child: Text(DateFormat('MMMM yyyy').format(m.date))),
              Text('${fmtNum(settings.toDisplay(m.value), decimals: 0)} ${settings.unitLabel}',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ]),
          ),
        ),
    ]);
  }
}
