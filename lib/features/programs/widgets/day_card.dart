import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../data/models.dart';

const weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

class DayCard extends StatelessWidget {
  final ProgramDay day;
  final int week;
  final Map<String, String> exerciseNames;
  final ValueChanged<String> onAction;
  final ValueChanged<ProgramExercise> onEditSets;
  final VoidCallback onAddExercise;
  final VoidCallback onStart;
  const DayCard({
    super.key,
    required this.day,
    required this.week,
    required this.exerciseNames,
    required this.onAction,
    required this.onEditSets,
    required this.onAddExercise,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final d = day;
    final has = d.hasWork(week);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text('${weekdayNames[d.weekday - 1]} · ${d.name}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ),
            if (d.tag.isNotEmpty) Chip(label: Text(d.tag), visualDensity: VisualDensity.compact),
            PopupMenuButton<String>(
              onSelected: (v) => onAction(v),
              itemBuilder: (c) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit day')),
                PopupMenuItem(value: 'delete', child: Text('Delete day')),
              ],
            ),
          ]),
          if (d.tag.isNotEmpty && describeTag(d.tag).isNotEmpty)
            Text(describeTag(d.tag), style: TextStyle(color: context.muted, fontSize: 12)),
          const SizedBox(height: 8),
          for (final pe in d.exercises)
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => onEditSets(pe),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(exerciseNames[pe.exerciseId] ?? pe.exerciseId,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      if (pe.forWeek(week).isEmpty)
                        Text('Nothing prescribed this week', style: TextStyle(color: context.muted, fontSize: 12))
                      else
                        for (final s in pe.forWeek(week))
                          Text(
                            '${s.describe()}${s.note.isEmpty ? '' : ' · ${s.note}'}',
                            style: TextStyle(color: context.muted, fontSize: 13),
                          ),
                    ]),
                  ),
                  Icon(Icons.edit_outlined, size: 16, color: context.muted),
                ]),
              ),
            ),
          const SizedBox(height: 8),
          Row(children: [
            TextButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Exercise'),
              onPressed: onAddExercise,
            ),
            const Spacer(),
            if (has)
              FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size(100, 40)),
                onPressed: onStart,
                child: Text('Start W${week + 1}'),
              ),
          ]),
        ]),
      ),
    );
  }
}
