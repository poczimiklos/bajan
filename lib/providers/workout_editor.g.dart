// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_editor.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds the workout being logged (or edited). Every change is persisted
/// locally (debounced), so an app kill or a dead battery never loses data.

@ProviderFor(WorkoutEditor)
final workoutEditorProvider = WorkoutEditorProvider._();

/// Holds the workout being logged (or edited). Every change is persisted
/// locally (debounced), so an app kill or a dead battery never loses data.
final class WorkoutEditorProvider
    extends $NotifierProvider<WorkoutEditor, Workout?> {
  /// Holds the workout being logged (or edited). Every change is persisted
  /// locally (debounced), so an app kill or a dead battery never loses data.
  WorkoutEditorProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'workoutEditorProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$workoutEditorHash();

  @$internal
  @override
  WorkoutEditor create() => WorkoutEditor();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Workout? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Workout?>(value),
    );
  }
}

String _$workoutEditorHash() => r'18700cebe1534f225500d7a8f7840053223a71df';

/// Holds the workout being logged (or edited). Every change is persisted
/// locally (debounced), so an app kill or a dead battery never loses data.

abstract class _$WorkoutEditor extends $Notifier<Workout?> {
  Workout? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Workout?, Workout?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<Workout?, Workout?>, Workout?, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
