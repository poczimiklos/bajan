import 'package:flutter/material.dart';
import '../../../data/models.dart';

class BlockSelector extends StatelessWidget {
  final List<ProgramBlock> blocks;
  final int selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onAdd;
  const BlockSelector(
      {super.key, required this.blocks, required this.selected, required this.onSelect, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(scrollDirection: Axis.horizontal, children: [
        for (var i = 0; i < blocks.length; i++)
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(label: Text(blocks[i].name), selected: selected == i, onSelected: (_) => onSelect(i)),
          ),
        ActionChip(avatar: const Icon(Icons.add, size: 18), label: const Text('Block'), onPressed: onAdd),
      ]),
    );
  }
}
