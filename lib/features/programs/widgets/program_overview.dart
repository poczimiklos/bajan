import 'package:flutter/material.dart';
import '../../../core/widgets/common.dart';
import '../../../data/models.dart';
import 'day_card.dart';

class ProgramOverview extends StatelessWidget {
  final ProgramBlock block;
  final List<ProgramDay> days;
  final Map<String, String> exerciseNames;

  const ProgramOverview({
    super.key,
    required this.block,
    required this.days,
    required this.exerciseNames,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionTitle('Full plan · ${block.weekCount} weeks'),
      AppCard(
        padding: EdgeInsets.zero,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              const DataColumn(label: SizedBox(width: 170, child: Text('Day / exercise'))),
              for (var week = 0; week < block.weekCount; week++)
                DataColumn(label: SizedBox(width: 150, child: Text('Week ${week + 1}'))),
            ],
            rows: [
              for (final day in days)
                for (final exercise in day.exercises)
                  DataRow(cells: [
                    DataCell(SizedBox(
                      width: 170,
                      child: Text(
                        '${weekdayNames[day.weekday - 1]} · ${day.name}\n${exerciseNames[exercise.exerciseId] ?? exercise.exerciseId}',
                      ),
                    )),
                    for (var week = 0; week < block.weekCount; week++)
                      DataCell(SizedBox(
                        width: 150,
                        child: Text(_prescriptionText(exercise.forWeek(week))),
                      )),
                  ]),
            ],
          ),
        ),
      ),
    ]);
  }

  String _prescriptionText(List<PrescribedSet> sets) {
    if (sets.isEmpty) return '—';
    return sets.map((set) {
      return [
        set.describe(),
        if (set.tempo.isNotEmpty) 'Tempo ${set.tempo}',
        if (set.note.isNotEmpty) set.note,
      ].where((part) => part.isNotEmpty).join(' · ');
    }).join('\n');
  }
}
