// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(exercises)
final exercisesProvider = ExercisesProvider._();

final class ExercisesProvider
    extends $FunctionalProvider<AsyncValue<List<Exercise>>, List<Exercise>, FutureOr<List<Exercise>>>
    with $FutureModifier<List<Exercise>>, $FutureProvider<List<Exercise>> {
  ExercisesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'exercisesProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$exercisesHash();

  @$internal
  @override
  $FutureProviderElement<List<Exercise>> $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Exercise>> create(Ref ref) {
    return exercises(ref);
  }
}

String _$exercisesHash() => r'2d76e16366cd7639a24cef9ed491517b78fe456d';

@ProviderFor(history)
final historyProvider = HistoryProvider._();

final class HistoryProvider
    extends $FunctionalProvider<AsyncValue<List<Workout>>, List<Workout>, FutureOr<List<Workout>>>
    with $FutureModifier<List<Workout>>, $FutureProvider<List<Workout>> {
  HistoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'historyProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$historyHash();

  @$internal
  @override
  $FutureProviderElement<List<Workout>> $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Workout>> create(Ref ref) {
    return history(ref);
  }
}

String _$historyHash() => r'38ee1c37a0a4f7e9a2dd9221b728c49e954c7374';

@ProviderFor(programs)
final programsProvider = ProgramsProvider._();

final class ProgramsProvider
    extends $FunctionalProvider<AsyncValue<List<Program>>, List<Program>, FutureOr<List<Program>>>
    with $FutureModifier<List<Program>>, $FutureProvider<List<Program>> {
  ProgramsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'programsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$programsHash();

  @$internal
  @override
  $FutureProviderElement<List<Program>> $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Program>> create(Ref ref) {
    return programs(ref);
  }
}

String _$programsHash() => r'8b3fc2f196d06ad0a5febb0d20c816826be5934c';

@ProviderFor(records)
final recordsProvider = RecordsProvider._();

final class RecordsProvider
    extends $FunctionalProvider<AsyncValue<List<PersonalRecord>>, List<PersonalRecord>, FutureOr<List<PersonalRecord>>>
    with $FutureModifier<List<PersonalRecord>>, $FutureProvider<List<PersonalRecord>> {
  RecordsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'recordsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$recordsHash();

  @$internal
  @override
  $FutureProviderElement<List<PersonalRecord>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<PersonalRecord>> create(Ref ref) {
    return records(ref);
  }
}

String _$recordsHash() => r'73f11d2e7359dc1141eb79695096a6949346c686';

@ProviderFor(bodyweight)
final bodyweightProvider = BodyweightProvider._();

final class BodyweightProvider extends $FunctionalProvider<AsyncValue<List<BodyweightEntry>>, List<BodyweightEntry>,
        FutureOr<List<BodyweightEntry>>>
    with $FutureModifier<List<BodyweightEntry>>, $FutureProvider<List<BodyweightEntry>> {
  BodyweightProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'bodyweightProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$bodyweightHash();

  @$internal
  @override
  $FutureProviderElement<List<BodyweightEntry>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<BodyweightEntry>> create(Ref ref) {
    return bodyweight(ref);
  }
}

String _$bodyweightHash() => r'5540dbb5c60da5dc8a9378a19909d0dc870cafec';

@ProviderFor(setRecords)
final setRecordsProvider = SetRecordsProvider._();

final class SetRecordsProvider
    extends $FunctionalProvider<AsyncValue<List<SetRecord>>, List<SetRecord>, FutureOr<List<SetRecord>>>
    with $FutureModifier<List<SetRecord>>, $FutureProvider<List<SetRecord>> {
  SetRecordsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'setRecordsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$setRecordsHash();

  @$internal
  @override
  $FutureProviderElement<List<SetRecord>> $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SetRecord>> create(Ref ref) {
    return setRecords(ref);
  }
}

String _$setRecordsHash() => r'beccedb3afa00222c6319e4856c2c84159085dac';

@ProviderFor(stats)
final statsProvider = StatsProvider._();

final class StatsProvider
    extends $FunctionalProvider<AsyncValue<StatsCalc>, AsyncValue<StatsCalc>, AsyncValue<StatsCalc>>
    with $Provider<AsyncValue<StatsCalc>> {
  StatsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'statsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$statsHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<StatsCalc>> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  AsyncValue<StatsCalc> create(Ref ref) {
    return stats(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<StatsCalc> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<StatsCalc>>(value),
    );
  }
}

String _$statsHash() => r'bcc5e0911581d90c45a96ea5b7b39eab658e8672';

@ProviderFor(activePlan)
final activePlanProvider = ActivePlanProvider._();

final class ActivePlanProvider extends $FunctionalProvider<AsyncValue<ActivePlan?>, ActivePlan?, FutureOr<ActivePlan?>>
    with $FutureModifier<ActivePlan?>, $FutureProvider<ActivePlan?> {
  ActivePlanProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'activePlanProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$activePlanHash();

  @$internal
  @override
  $FutureProviderElement<ActivePlan?> $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<ActivePlan?> create(Ref ref) {
    return activePlan(ref);
  }
}

String _$activePlanHash() => r'6f4e4b24e49cdcbbbf1ea14136b192b54d1bed92';

@ProviderFor(programDetail)
final programDetailProvider = ProgramDetailFamily._();

final class ProgramDetailProvider extends $FunctionalProvider<AsyncValue<Program?>, Program?, FutureOr<Program?>>
    with $FutureModifier<Program?>, $FutureProvider<Program?> {
  ProgramDetailProvider._({required ProgramDetailFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'programDetailProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$programDetailHash();

  @override
  String toString() {
    return r'programDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Program?> $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<Program?> create(Ref ref) {
    final argument = this.argument as String;
    return programDetail(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProgramDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$programDetailHash() => r'93e4139e9a13c98799448928543b6b1bbe4ae159';

final class ProgramDetailFamily extends $Family with $FunctionalFamilyOverride<FutureOr<Program?>, String> {
  ProgramDetailFamily._()
      : super(
          retry: null,
          name: r'programDetailProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  ProgramDetailProvider call(
    String id,
  ) =>
      ProgramDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'programDetailProvider';
}

/// Previous performance of an exercise in workouts other than [workoutId].

@ProviderFor(lastPerformance)
final lastPerformanceProvider = LastPerformanceFamily._();

/// Previous performance of an exercise in workouts other than [workoutId].

final class LastPerformanceProvider
    extends $FunctionalProvider<AsyncValue<List<SetEntry>>, List<SetEntry>, FutureOr<List<SetEntry>>>
    with $FutureModifier<List<SetEntry>>, $FutureProvider<List<SetEntry>> {
  /// Previous performance of an exercise in workouts other than [workoutId].
  LastPerformanceProvider._(
      {required LastPerformanceFamily super.from,
      required (
        String,
        String,
      )
          super.argument})
      : super(
          retry: null,
          name: r'lastPerformanceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$lastPerformanceHash();

  @override
  String toString() {
    return r'lastPerformanceProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<SetEntry>> $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SetEntry>> create(Ref ref) {
    final argument = this.argument as (
      String,
      String,
    );
    return lastPerformance(
      ref,
      argument.$1,
      argument.$2,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LastPerformanceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lastPerformanceHash() => r'6e886bbe2e13a90435ef914dad099425f9c6f037';

/// Previous performance of an exercise in workouts other than [workoutId].

final class LastPerformanceFamily extends $Family
    with
        $FunctionalFamilyOverride<
            FutureOr<List<SetEntry>>,
            (
              String,
              String,
            )> {
  LastPerformanceFamily._()
      : super(
          retry: null,
          name: r'lastPerformanceProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: false,
        );

  /// Previous performance of an exercise in workouts other than [workoutId].

  LastPerformanceProvider call(
    String exerciseId,
    String workoutId,
  ) =>
      LastPerformanceProvider._(argument: (
        exerciseId,
        workoutId,
      ), from: this);

  @override
  String toString() => r'lastPerformanceProvider';
}
