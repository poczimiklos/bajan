import 'package:flutter_test/flutter_test.dart';
import 'package:powerlifting_tracker/data/seed_exercises.dart';
import 'package:powerlifting_tracker/data/sheet_program.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('imports every worksheet with its own training duration', () async {
    final imported = await sheetCoachProgram();
    final program = imported.program;

    expect(program.name, sheetProgramName);
    expect(
      program.blocks.map((block) => block.name),
      [
        '08.04',
        '06.30',
        '05.25',
        '04.21',
        '03.16-04.18',
        'M2-C1 2026.02.09-',
        'M1-C5 2026.01.05-',
        'M1-C4 12.01-01.04',
        'M1-C3 10.27-11.30',
        'M1-C2 09.22-10.25',
        'M1-C1 2025.08.18-09.21',
      ],
    );
    expect(
      program.blocks.map((block) => block.weekCount),
      [5, 5, 5, 5, 5, 4, 4, 5, 5, 5, 5],
    );
    expect(program.blocks.every((block) => block.days.length == 3), isTrue);
    expect(program.blocks.every((block) => block.days.every((day) => day.exercises.isNotEmpty)), isTrue);
    for (final block in program.blocks) {
      for (final day in block.days) {
        expect(
          List.generate(block.weekCount, day.hasWork),
          everyElement(isTrue),
          reason: '${block.name} ${day.name} should have prescriptions for every week',
        );
      }
    }

    final knownIds = {
      ...seedExercises.map((exercise) => exercise.id),
      ...imported.customExercises.map((exercise) => exercise.id),
    };
    expect(
      program.blocks
          .expand((block) => block.days)
          .expand((day) => day.exercises)
          .every((exercise) => knownIds.contains(exercise.exerciseId)),
      isTrue,
    );
    expect(program.blocks.first.startDate, DateTime(2026, 8, 4));
  });

  test('keeps prescribed RPE and omits malformed working weights', () async {
    final program = (await sheetCoachProgram()).program;
    final firstBlock = program.blocks.first;
    final day1Squat = firstBlock.days.first.exercises.singleWhere((exercise) => exercise.exerciseId == 'low_bar_squat');
    expect(day1Squat.forWeek(0).first.weight, 195);
    expect(day1Squat.forWeek(0).first.rpeMin, 4);

    final day3Squat = firstBlock.days.last.exercises.singleWhere((exercise) => exercise.exerciseId == 'low_bar_squat');
    expect(day3Squat.forWeek(0).any((set) => set.weight == 5), isFalse);
    expect(day3Squat.forWeek(0).any((set) => set.note.contains('Sheet load omitted')), isTrue);
  });
}
