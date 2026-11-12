import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../data/models.dart';
import '../../../providers/providers.dart';

// ─────────────────────────── Header / check-in ───────────────────────────

class WorkoutHeader extends ConsumerWidget {
  final Workout workout;
  const WorkoutHeader({super.key, required this.workout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = workout;
    final editor = ref.read(workoutEditorProvider.notifier);
    final checked = w.stress != null || w.fatigueSq != null || w.fatigueBp != null || w.fatigueDl != null;
    Widget scale(String label, int? value, void Function(int) onPick) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            SizedBox(width: 70, child: Text(label, style: TextStyle(color: context.muted))),
            for (var i = 1; i <= 5; i++)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text('$i'),
                  selected: value == i,
                  onSelected: (_) => onPick(i),
                  visualDensity: VisualDensity.compact,
                ),
              ),
          ]),
        );
    return Column(children: [
      if (w.tag.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: [
            Chip(label: Text(w.tag, style: const TextStyle(fontWeight: FontWeight.w700))),
            const SizedBox(width: 8),
            Expanded(child: Text(describeTag(w.tag), style: TextStyle(color: context.muted, fontSize: 12))),
          ]),
        ),
      AppCard(
        padding: EdgeInsets.zero,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: const Text('Check-in', style: TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(
              checked
                  ? 'Stress ${w.stress ?? '–'} · SQ ${w.fatigueSq ?? '–'} · BP ${w.fatigueBp ?? '–'} · DL ${w.fatigueDl ?? '–'}'
                  : 'Stress and fatigue (1 = low, 5 = high)',
              style: TextStyle(color: context.muted, fontSize: 12),
            ),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            children: [
              scale('Stress', w.stress, (v) => editor.setCheckIn(stress: v)),
              scale('Fatigue SQ', w.fatigueSq, (v) => editor.setCheckIn(sq: v)),
              scale('Fatigue BP', w.fatigueBp, (v) => editor.setCheckIn(bp: v)),
              scale('Fatigue DL', w.fatigueDl, (v) => editor.setCheckIn(dl: v)),
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
    ]);
  }
}
