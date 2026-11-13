import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/block1_program.dart';
import 'infrastructure.dart';
import 'data_providers.dart';
import 'settings_provider.dart';
import 'workout_editor.dart';

part 'bootstrap_provider.g.dart';

/// Seeds the exercise library and restores an unfinished workout.
@Riverpod(keepAlive: true)
Future<void> bootstrap(Ref ref) async {
  final exercises = ref.read(exerciseRepoProvider);
  await exercises.seedIfNeeded();
  final programs = ref.read(programRepoProvider);
  final preferences = ref.read(sharedPrefsProvider);
  if (preferences.getBool(block1ImportPreferenceKey) != true) {
    if (await programs.existsByName(block1ProgramName)) {
      await preferences.setBool(block1ImportPreferenceKey, true);
    } else {
      await programs.save(await createBlock1Program(exercises));
      await preferences.setBool(block1ImportPreferenceKey, true);
      ref.invalidate(programsProvider);
    }
  }
  var removedCoachPlan = false;
  for (final program in await programs.all()) {
    if (program.name == 'Miklós · Coach plan') {
      final activeBlockId = ref.read(settingsProvider).activeBlockId;
      if (program.blocks.any((block) => block.id == activeBlockId)) {
        await ref.read(settingsProvider.notifier).update((settings) => settings.copyWith(activeBlockId: null));
      }
      await programs.delete(program.id);
      removedCoachPlan = true;
    }
  }
  if (removedCoachPlan) {
    ref
      ..invalidate(programsProvider)
      ..invalidate(activePlanProvider);
  }
  await ref.read(workoutEditorProvider.notifier).restoreActive();
}
