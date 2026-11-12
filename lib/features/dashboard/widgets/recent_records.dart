import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../data/models.dart';
import '../../training/widgets/pr_dialog.dart';

import '../../../data/settings.dart';

class RecentRecords extends StatelessWidget {
  final List<PersonalRecord> records;
  final AppSettings settings;
  const RecentRecords({super.key, required this.records, required this.settings});

  @override
  Widget build(BuildContext context) {
    final recent = records.where((r) => r.previous != null && r.kind != 'reps').take(4).toList();
    return Column(children: [
      if (recent.isEmpty)
        AppCard(
            child: Text('No new records yet. They appear automatically when you beat a previous best.',
                style: TextStyle(color: context.muted)))
      else
        for (final r in recent)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                Icon(Icons.emoji_events, color: context.accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r.exerciseName, style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text('${r.kindLabel} · ${DateFormat('d MMM').format(r.date)}',
                        style: TextStyle(color: context.muted, fontSize: 12)),
                  ]),
                ),
                Text(prValueText(r, settings), style: TextStyle(color: context.accent, fontWeight: FontWeight.w800)),
              ]),
            ),
          ),
    ]);
  }
}
