import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models.dart';
import 'infrastructure.dart';
import 'settings_provider.dart';

part 'workout_editor.g.dart';

/// Holds the workout being logged (or edited). Every change is persisted
/// locally (debounced), so an app kill or a dead battery never loses data.
@Riverpod(keepAlive: true)
class WorkoutEditor extends _$WorkoutEditor {
  Timer? _debounce;

  @override
  Workout? build() {
    ref.onDispose(() => _debounce?.cancel());
    return null;
  }

  Future<void> restoreActive() async => state = await ref.read(workoutRepoProvider).active();

  Future<void> start(Workout w) async {
    state = w;
    await ref.read(workoutRepoProvider).save(w);
  }

  Future<void> startEmpty() => start(Workout(name: 'Workout'));

  Future<void> loadForEdit(String id) async => state = await ref.read(workoutRepoProvider).load(id);

  void closeEditor() {
    _debounce?.cancel();
    state = null;
  }

  // ── mutation helpers ──
  void _changed() {
    final w = state;
    if (w == null) return;
    state = w.copyRef();
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final cur = state;
      if (cur != null) ref.read(workoutRepoProvider).save(cur);
    });
  }

  WorkoutExercise? _we(String id) => state?.exercises.where((e) => e.id == id).firstOrNull;

  void rename(String name) {
    state?.name = name;
    _changed();
  }

  void setNotes(String notes) {
    state?.notes = notes;
    _changed();
  }

  void setCheckIn({int? stress, int? sq, int? bp, int? dl}) {
    final w = state;
    if (w == null) return;
    if (stress != null) w.stress = stress;
    if (sq != null) w.fatigueSq = sq;
    if (bp != null) w.fatigueBp = bp;
    if (dl != null) w.fatigueDl = dl;
    _changed();
  }

  Future<void> addExercise(Exercise ex) async {
    final w = state;
    if (w == null) return;
    final last = await ref.read(workoutRepoProvider).lastPerformance(ex.id, excludeWorkoutId: w.id);
    final we = WorkoutExercise(exercise: ex);
    if (last.isEmpty) {
      we.sets.add(SetEntry());
    } else {
      for (final s in last) {
        we.sets.add(SetEntry(type: s.type, weight: s.weight, reps: s.reps));
      }
    }
    w.exercises.add(we);
    _changed();
  }

  void removeExercise(String weId) {
    state?.exercises.removeWhere((e) => e.id == weId);
    _changed();
  }

  void moveExercise(String weId, int delta) {
    final list = state?.exercises;
    if (list == null) return;
    final i = list.indexWhere((e) => e.id == weId);
    final j = i + delta;
    if (i < 0 || j < 0 || j >= list.length) return;
    final e = list.removeAt(i);
    list.insert(j, e);
    _changed();
  }

  void setExerciseNotes(String weId, String notes) {
    _we(weId)?.notes = notes;
    _changed();
  }

  void setTempo(String weId, String tempo) {
    _we(weId)?.tempo = tempo;
    _changed();
  }

  void addSet(String weId) {
    final we = _we(weId);
    if (we == null) return;
    final last = we.sets.isEmpty ? null : we.sets.last;
    we.sets.add(SetEntry(
      type: last == null || last.type == SetType.warmup ? SetType.working : last.type,
      weight: last?.weight,
      reps: last?.reps,
      rpe: null,
    ));
    _changed();
  }

  void removeSet(String weId, String setId) {
    _we(weId)?.sets.removeWhere((s) => s.id == setId);
    _changed();
  }

  /// Re-inserts a removed set (used by the swipe-to-delete undo).
  void insertSet(String weId, int index, SetEntry set) {
    final we = _we(weId);
    if (we == null) return;
    we.sets.insert(index.clamp(0, we.sets.length), set);
    _changed();
  }

  void updateSet(String weId, String setId, void Function(SetEntry s) change) {
    final s = _we(weId)?.sets.where((s) => s.id == setId).firstOrNull;
    if (s == null) return;
    change(s);
    _changed();
  }

  void cycleSetType(String weId, String setId) {
    updateSet(weId, setId, (s) {
      final i = SetType.all.indexOf(s.type);
      s.type = SetType.all[(i + 1) % SetType.all.length];
    });
  }

  // ── lifecycle ──

  /// Marks the workout done, stores it, detects PRs. Returns new PRs.
  Future<List<PersonalRecord>> finish() async {
    _debounce?.cancel();
    final w = state;
    if (w == null) return [];
    for (final we in w.exercises) {
      we.sets.removeWhere((s) => !s.completed && s.weight == null && s.reps == null);
    }
    w.exercises.removeWhere((e) => e.sets.isEmpty);
    w.status = 'done';
    w.endedAt ??= DateTime.now();
    await ref.read(workoutRepoProvider).save(w);
    final prs = await ref.read(recordRepoProvider).detectAndStore(w, ref.read(settingsProvider).formula);
    state = null;
    return prs;
  }

  Future<void> discard() async {
    _debounce?.cancel();
    final w = state;
    state = null;
    if (w != null) await ref.read(workoutRepoProvider).delete(w.id);
  }
}
