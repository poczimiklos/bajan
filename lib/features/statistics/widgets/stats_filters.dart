import 'package:flutter/material.dart';
import '../../../data/models.dart';

const statsRanges = <(String, int?)>[
  ('7D', 7),
  ('30D', 30),
  ('90D', 90),
  ('6M', 182),
  ('1Y', 365),
  ('All', null),
];

class StatsFilters extends StatelessWidget {
  final int range;
  final String lift;
  final ValueChanged<int> onRange;
  final ValueChanged<String> onLift;
  const StatsFilters({super.key, required this.range, required this.lift, required this.onRange, required this.onLift});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SizedBox(
        height: 40,
        child: ListView(scrollDirection: Axis.horizontal, children: [
          for (var i = 0; i < statsRanges.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(label: Text(statsRanges[i].$1), selected: range == i, onSelected: (_) => onRange(i)),
            ),
        ]),
      ),
      const SizedBox(height: 8),
      Wrap(spacing: 6, children: [
        for (final l in const ['total', ...Lift.all])
          ChoiceChip(
            label: Text(l == 'total' ? 'SBD total' : Lift.label(l)),
            selected: lift == l,
            onSelected: (_) => onLift(l),
          ),
      ]),
    ]);
  }
}
