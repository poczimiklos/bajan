import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models.dart';
import '../data/sheet_program.dart';
import 'infrastructure.dart';
import 'workout_editor.dart';

part 'bootstrap_provider.g.dart';

/// Seeds the exercise library and restores an unfinished workout.
@Riverpod(keepAlive: true)
Future<void> bootstrap(Ref ref) async {
  final exercises = ref.read(exerciseRepoProvider);
  await exercises.seedIfNeeded();
  final imported = await sheetCoachProgram();
  final existingExerciseIds = (await exercises.map()).keys.toSet();
  for (final exercise in imported.customExercises) {
    if (existingExerciseIds.add(exercise.id)) {
      await exercises.save(exercise);
    }
  }

  final programs = ref.read(programRepoProvider);
  Program? existing;
  for (final program in await programs.all()) {
    if (program.name == sheetProgramName) {
      existing = program;
      break;
    }
  }
  if (existing == null) {
    await programs.save(imported.program);
  } else {
    var changed = false;
    final firstSheetDate = imported.program.blocks.first.startDate;
    if (existing.blocks.length == 1 &&
        existing.blocks.single.name == 'Block 1' &&
        _sameDate(existing.blocks.single.startDate, firstSheetDate)) {
      existing.blocks.single.name = imported.program.blocks.first.name;
      changed = true;
    }

    final existingBlockNames = existing.blocks.map((block) => block.name).toSet();
    for (final block in imported.program.blocks) {
      if (existingBlockNames.add(block.name)) {
        existing.blocks.add(block);
        changed = true;
      }
    }
    if (changed) {
      existing.description = imported.program.description;
      await programs.save(existing);
    }
  }
  await ref.read(workoutEditorProvider.notifier).restoreActive();
}

bool _sameDate(DateTime? first, DateTime? second) =>
    first != null &&
    second != null &&
    first.year == second.year &&
    first.month == second.month &&
    first.day == second.day;
