// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'infrastructure.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sharedPrefs)
final sharedPrefsProvider = SharedPrefsProvider._();

final class SharedPrefsProvider extends $FunctionalProvider<SharedPreferences,
    SharedPreferences, SharedPreferences> with $Provider<SharedPreferences> {
  SharedPrefsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'sharedPrefsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sharedPrefsHash();

  @$internal
  @override
  $ProviderElement<SharedPreferences> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SharedPreferences create(Ref ref) {
    return sharedPrefs(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharedPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharedPreferences>(value),
    );
  }
}

String _$sharedPrefsHash() => r'd6c2939f50c75515ea472436d4a4b8f66e217799';

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  AppDatabaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'appDatabaseProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'98a09c6cfd43966155dfbdb0787fa18c85438e13';

@ProviderFor(exerciseRepo)
final exerciseRepoProvider = ExerciseRepoProvider._();

final class ExerciseRepoProvider extends $FunctionalProvider<ExerciseRepository,
    ExerciseRepository, ExerciseRepository> with $Provider<ExerciseRepository> {
  ExerciseRepoProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'exerciseRepoProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$exerciseRepoHash();

  @$internal
  @override
  $ProviderElement<ExerciseRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ExerciseRepository create(Ref ref) {
    return exerciseRepo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExerciseRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExerciseRepository>(value),
    );
  }
}

String _$exerciseRepoHash() => r'f4e8c75d7ad2ff6f5f3319a74e9da57d0d18f96b';

@ProviderFor(workoutRepo)
final workoutRepoProvider = WorkoutRepoProvider._();

final class WorkoutRepoProvider extends $FunctionalProvider<WorkoutRepository,
    WorkoutRepository, WorkoutRepository> with $Provider<WorkoutRepository> {
  WorkoutRepoProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'workoutRepoProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$workoutRepoHash();

  @$internal
  @override
  $ProviderElement<WorkoutRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WorkoutRepository create(Ref ref) {
    return workoutRepo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkoutRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorkoutRepository>(value),
    );
  }
}

String _$workoutRepoHash() => r'2c6d8dca3f0b16b915d4851f9a720e0c6f1f5cb1';

@ProviderFor(programRepo)
final programRepoProvider = ProgramRepoProvider._();

final class ProgramRepoProvider extends $FunctionalProvider<ProgramRepository,
    ProgramRepository, ProgramRepository> with $Provider<ProgramRepository> {
  ProgramRepoProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'programRepoProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$programRepoHash();

  @$internal
  @override
  $ProviderElement<ProgramRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ProgramRepository create(Ref ref) {
    return programRepo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProgramRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProgramRepository>(value),
    );
  }
}

String _$programRepoHash() => r'ff03ae25d35a86a83fd7438b943137bf2e994be4';

@ProviderFor(recordRepo)
final recordRepoProvider = RecordRepoProvider._();

final class RecordRepoProvider extends $FunctionalProvider<RecordRepository,
    RecordRepository, RecordRepository> with $Provider<RecordRepository> {
  RecordRepoProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'recordRepoProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$recordRepoHash();

  @$internal
  @override
  $ProviderElement<RecordRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RecordRepository create(Ref ref) {
    return recordRepo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecordRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecordRepository>(value),
    );
  }
}

String _$recordRepoHash() => r'57470a2ca1afd4524823e62cc05f527176e6d976';

@ProviderFor(bodyweightRepo)
final bodyweightRepoProvider = BodyweightRepoProvider._();

final class BodyweightRepoProvider extends $FunctionalProvider<
    BodyweightRepository,
    BodyweightRepository,
    BodyweightRepository> with $Provider<BodyweightRepository> {
  BodyweightRepoProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'bodyweightRepoProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$bodyweightRepoHash();

  @$internal
  @override
  $ProviderElement<BodyweightRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BodyweightRepository create(Ref ref) {
    return bodyweightRepo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BodyweightRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BodyweightRepository>(value),
    );
  }
}

String _$bodyweightRepoHash() => r'658eac9dac59716a8699e5d476ec5e880322a01d';

@ProviderFor(backupService)
final backupServiceProvider = BackupServiceProvider._();

final class BackupServiceProvider
    extends $FunctionalProvider<BackupService, BackupService, BackupService>
    with $Provider<BackupService> {
  BackupServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'backupServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$backupServiceHash();

  @$internal
  @override
  $ProviderElement<BackupService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BackupService create(Ref ref) {
    return backupService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackupService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackupService>(value),
    );
  }
}

String _$backupServiceHash() => r'07bce273ebfd8738845610d8805992b960a79991';

/// Override with a real backend adapter to enable cloud sync.

@ProviderFor(remoteGateway)
final remoteGatewayProvider = RemoteGatewayProvider._();

/// Override with a real backend adapter to enable cloud sync.

final class RemoteGatewayProvider
    extends $FunctionalProvider<RemoteGateway, RemoteGateway, RemoteGateway>
    with $Provider<RemoteGateway> {
  /// Override with a real backend adapter to enable cloud sync.
  RemoteGatewayProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'remoteGatewayProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$remoteGatewayHash();

  @$internal
  @override
  $ProviderElement<RemoteGateway> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RemoteGateway create(Ref ref) {
    return remoteGateway(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RemoteGateway value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RemoteGateway>(value),
    );
  }
}

String _$remoteGatewayHash() => r'3a9c9b2f22e371b276e36d2b9476c053ea2cfd6c';

@ProviderFor(syncService)
final syncServiceProvider = SyncServiceProvider._();

final class SyncServiceProvider
    extends $FunctionalProvider<SyncService, SyncService, SyncService>
    with $Provider<SyncService> {
  SyncServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'syncServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$syncServiceHash();

  @$internal
  @override
  $ProviderElement<SyncService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncService create(Ref ref) {
    return syncService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncService>(value),
    );
  }
}

String _$syncServiceHash() => r'2e1e9a8a558f414ef493f5122bfbcbc33f177c0b';

@ProviderFor(syncStatus)
final syncStatusProvider = SyncStatusProvider._();

final class SyncStatusProvider extends $FunctionalProvider<
        AsyncValue<SyncStatus>, SyncStatus, FutureOr<SyncStatus>>
    with $FutureModifier<SyncStatus>, $FutureProvider<SyncStatus> {
  SyncStatusProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'syncStatusProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$syncStatusHash();

  @$internal
  @override
  $FutureProviderElement<SyncStatus> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SyncStatus> create(Ref ref) {
    return syncStatus(ref);
  }
}

String _$syncStatusHash() => r'94f55c85dc7223d459cf7962235e9cdcbf59c75c';
