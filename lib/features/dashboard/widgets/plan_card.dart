import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../training/plan.dart';
import '../../training/start_workout.dart';

class PlanCard extends ConsumerWidget {
  final ActivePlan? plan;
  final bool loading;
  const PlanCard({super.key, required this.plan, required this.loading});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = plan;
    if (p == null) {
      return AppCard(
        onTap: loading ? null : () => context.go('/programs'),
        child: Row(children: [
          Icon(Icons.event_note, color: context.accent),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('No active program. Pick or build one in Programs.',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          const Icon(Icons.chevron_right),
        ]),
      );
    }
    final day = p.today;
    final df = DateFormat('EEE d MMM');
    String sub;
    if (p.notStarted) {
      sub = 'Starts ${df.format(p.block.startDate!)}';
    } else if (p.finished) {
      sub = 'Block finished';
    } else if (day != null) {
      sub = 'Today: ${day.name}';
    } else if (p.next != null) {
      sub = 'Rest day · next: ${p.next!.name} on ${df.format(p.nextDate!)}';
    } else {
      sub = 'Nothing scheduled';
    }
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(p.program.name, style: TextStyle(color: context.muted, fontSize: 12)),
        const SizedBox(height: 2),
        Row(children: [
          Expanded(
              child: Text('${p.block.name} · ${p.finished ? 'done' : p.weekLabel}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
          if (day != null && day.tag.isNotEmpty) Chip(label: Text(day.tag), visualDensity: VisualDensity.compact),
        ]),
        const SizedBox(height: 6),
        Text(sub, style: TextStyle(color: context.muted)),
        if (!p.finished && !p.notStarted)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: LinearProgressIndicator(
              value: (p.week + 1) / p.block.weekCount,
              minHeight: 6,
              borderRadius: BorderRadius.zero,
              color: context.accent,
              backgroundColor: context.fieldBg,
            ),
          ),
        if (day != null) ...[
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: Text('Start ${day.name}'),
              onPressed: () => StartWorkout.fromPlan(context, ref, p),
            ),
          ),
        ] else if (p.next != null) ...[
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.fast_forward),
              label: Text('Do ${p.next!.name} now'),
              onPressed: () => StartWorkout.fromPlan(context, ref, p, useNext: true),
            ),
          ),
        ],
      ]),
    );
  }
}
