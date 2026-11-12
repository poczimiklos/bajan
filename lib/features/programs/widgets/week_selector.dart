import 'package:flutter/material.dart';

class WeekSelector extends StatelessWidget {
  final int weekCount;
  final int selected;
  final ValueChanged<int> onSelect;
  const WeekSelector({super.key, required this.weekCount, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(scrollDirection: Axis.horizontal, children: [
        for (var w = 0; w < weekCount; w++)
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(label: Text('W${w + 1}'), selected: selected == w, onSelected: (_) => onSelect(w)),
          ),
      ]),
    );
  }
}
