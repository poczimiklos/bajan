import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models.dart';
import '../../checkin/checkin_card.dart';

// ─────────────────────────── Header / check-in ───────────────────────────

class WorkoutHeader extends ConsumerWidget {
  final Workout workout;
  const WorkoutHeader({super.key, required this.workout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = workout;
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
      const CheckInCard(),
      const SizedBox(height: 12),
    ]);
  }
}
