import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'infrastructure.dart';
import 'workout_editor.dart';

part 'bootstrap_provider.g.dart';

/// Seeds the exercise library and restores an unfinished workout.
@Riverpod(keepAlive: true)
Future<void> bootstrap(Ref ref) async {
  await ref.read(exerciseRepoProvider).seedIfNeeded();
  await ref.read(workoutEditorProvider.notifier).restoreActive();
}
