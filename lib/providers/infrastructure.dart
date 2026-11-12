import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/backup_service.dart';
import '../data/database.dart';
import '../data/repositories/bodyweight_repository.dart';
import '../data/repositories/exercise_repository.dart';
import '../data/repositories/program_repository.dart';
import '../data/repositories/record_repository.dart';
import '../data/repositories/workout_repository.dart';
import '../data/sync_service.dart';

part 'infrastructure.g.dart';

@Riverpod(keepAlive: true)
SharedPreferences sharedPrefs(Ref ref) => throw UnimplementedError('override in main()');

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) => AppDatabase();

@Riverpod(keepAlive: true)
ExerciseRepository exerciseRepo(Ref ref) => ExerciseRepository(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
WorkoutRepository workoutRepo(Ref ref) =>
    WorkoutRepository(ref.watch(appDatabaseProvider), ref.watch(exerciseRepoProvider));

@Riverpod(keepAlive: true)
ProgramRepository programRepo(Ref ref) => ProgramRepository(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
RecordRepository recordRepo(Ref ref) => RecordRepository(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
BodyweightRepository bodyweightRepo(Ref ref) => BodyweightRepository(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
BackupService backupService(Ref ref) => BackupService(ref.watch(appDatabaseProvider));

/// Override with a real backend adapter to enable cloud sync.
@Riverpod(keepAlive: true)
RemoteGateway remoteGateway(Ref ref) => NoRemote();

@Riverpod(keepAlive: true)
SyncService syncService(Ref ref) => SyncService(ref.watch(appDatabaseProvider), ref.watch(remoteGatewayProvider));

@riverpod
Future<SyncStatus> syncStatus(Ref ref) => ref.watch(syncServiceProvider).status();
