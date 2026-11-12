import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../data/models.dart';

class BlockCard extends StatelessWidget {
  final ProgramBlock block;
  final bool isActive;
  final VoidCallback onActivate;
  final VoidCallback onNextBlock;
  final VoidCallback onSettings;
  const BlockCard({
    super.key,
    required this.block,
    required this.isActive,
    required this.onActivate,
    required this.onNextBlock,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(
              '${block.name} · ${block.weekCount} weeks'
              '${block.startDate == null ? '' : ' · from ${DateFormat('d MMM yyyy').format(block.startDate!)}'}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          if (isActive)
            Chip(
                label: const Text('Active'),
                visualDensity: VisualDensity.compact,
                backgroundColor: context.accent.withValues(alpha: 0.25)),
        ]),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 4, children: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(minimumSize: const Size(48, 40)),
            onPressed: () => onActivate(),
            child: Text(isActive ? 'Change start date' : 'Activate block'),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(minimumSize: const Size(48, 40)),
            onPressed: () => onNextBlock(),
            child: const Text('Create next block'),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(minimumSize: const Size(48, 40)),
            onPressed: () => onSettings(),
            child: const Text('Block settings'),
          ),
        ]),
      ]),
    );
  }
}
