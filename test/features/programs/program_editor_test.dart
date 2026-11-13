import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powerlifting_tracker/data/models.dart';
import 'package:powerlifting_tracker/features/programs/widgets/program_editor.dart';

void main() {
  testWidgets('edits prescription fields inline and reports week selection', (tester) async {
    final set = PrescribedSet(id: 'set-1', weekIndex: 0, sets: 3, repsMin: 5, repsMax: 5);
    final exercise = ProgramExercise(id: 'exercise-1', exerciseId: 'squat', sets: [set]);
    final day = ProgramDay(
      id: 'day-1',
      name: 'Day 1',
      weekday: DateTime.monday,
      exercises: [exercise],
    );
    var selectedWeek = -1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProgramEditor(
              block: ProgramBlock(name: 'Block 1', weekCount: 2, days: [day]),
              days: [day],
              day: day,
              week: 0,
              exercises: const [Exercise(id: 'squat', name: 'Squat')],
              unit: 'kg',
              onSelectWeek: (week) => selectedWeek = week,
              onSelectDay: (_) {},
              onAddDay: () {},
              onDayAction: (_) {},
              onAddExercise: () {},
              onChooseExercise: (_) {},
              onDeleteExercise: (_) {},
              onAddSet: (_, __) {},
              onDeleteSet: (_, __) {},
              onSave: () {},
              onStart: () {},
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('set-1-load')), '102.5');
    await tester.enterText(find.byKey(const ValueKey('set-1-rpe')), '8.5');
    expect(set.weight, 102.5);
    expect(set.rpeMin, 8.5);

    await tester.tap(find.text('Week 2').first);
    expect(selectedWeek, 1);
  });
}
