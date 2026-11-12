import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models.dart';
import '../domain/stats.dart';
import '../features/training/plan.dart';
import 'infrastructure.dart';
import 'settings_provider.dart';

part 'data_providers.g.dart';

@Riverpod(keepAlive: true)
Future<List<Exercise>> exercises(Ref ref) => ref.watch(exerciseRepoProvider).all();

@Riverpod(keepAlive: true)
Future<List<Workout>> history(Ref ref) => ref.watch(workoutRepoProvider).history();

@Riverpod(keepAlive: true)
Future<List<Program>> programs(Ref ref) => ref.watch(programRepoProvider).all();

@Riverpod(keepAlive: true)
Future<List<PersonalRecord>> records(Ref ref) => ref.watch(recordRepoProvider).all();

@Riverpod(keepAlive: true)
Future<List<BodyweightEntry>> bodyweight(Ref ref) => ref.watch(bodyweightRepoProvider).all();

@Riverpod(keepAlive: true)
Future<List<SetRecord>> setRecords(Ref ref) => ref.watch(workoutRepoProvider).setRecords();

@Riverpod(keepAlive: true)
AsyncValue<StatsCalc> stats(Ref ref) {
  final formula = ref.watch(settingsProvider.select((s) => s.formula));
  return ref.watch(setRecordsProvider).whenData((r) => StatsCalc(r, formula));
}

@Riverpod(keepAlive: true)
Future<ActivePlan?> activePlan(Ref ref) async {
  final blockId = ref.watch(settingsProvider.select((s) => s.activeBlockId));
  if (blockId == null) return null;
  final program = await ref.watch(programRepoProvider).loadByBlock(blockId);
  if (program == null) return null;
  final block = program.blocks.where((b) => b.id == blockId).firstOrNull;
  if (block == null) return null;
  return ActivePlan.compute(program, block, DateTime.now());
}

@riverpod
Future<Program?> programDetail(Ref ref, String id) => ref.watch(programRepoProvider).load(id);

/// Previous performance of an exercise in workouts other than [workoutId].
@Riverpod(keepAlive: true)
Future<List<SetEntry>> lastPerformance(Ref ref, String exerciseId, String workoutId) =>
    ref.watch(workoutRepoProvider).lastPerformance(exerciseId, excludeWorkoutId: workoutId);
