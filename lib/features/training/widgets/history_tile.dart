import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../data/models.dart';
import '../../../providers/providers.dart';

class HistoryTile extends ConsumerWidget {
  final Workout workout;
  final String unit;
  final double Function(double) toDisplay;
  const HistoryTile({super.key, required this.workout, required this.unit, required this.toDisplay});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = workout;
    final sets = w.completedSets.length;
    final names = w.exercises.map((e) => e.exercise.name).take(3).join(', ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: () async {
          await ref.read(workoutEditorProvider.notifier).loadForEdit(w.id);
          if (context.mounted) context.push('/workout');
        },
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(w.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
            if (w.tag.isNotEmpty) Chip(label: Text(w.tag), visualDensity: VisualDensity.compact),
            const SizedBox(width: 6),
            Text(DateFormat('EEE d MMM').format(w.date), style: TextStyle(color: context.muted, fontSize: 12)),
          ]),
          const SizedBox(height: 6),
          Text(names + (w.exercises.length > 3 ? ' +${w.exercises.length - 3}' : ''),
              style: TextStyle(color: context.muted), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Row(children: [
            _pill(context, Icons.layers, '$sets sets'),
            const SizedBox(width: 12),
            _pill(context, Icons.scale, '${fmtNum(toDisplay(w.volume), decimals: 0)} $unit'),
            if (w.endedAt != null) ...[
              const SizedBox(width: 12),
              _pill(context, Icons.timer_outlined, '${w.endedAt!.difference(w.startedAt).inMinutes} min'),
            ],
          ]),
        ]),
      ),
    );
  }

  Widget _pill(BuildContext c, IconData i, String t) => Row(children: [
        Icon(i, size: 14, color: c.muted),
        const SizedBox(width: 4),
        Text(t, style: TextStyle(fontSize: 12, color: c.muted)),
      ]);
}
