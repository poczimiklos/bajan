import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../providers/providers.dart';
import 'widgets/exercise_picker.dart';
import 'widgets/pr_dialog.dart';
import 'widgets/rest_timer.dart';
import 'widgets/elapsed_timer.dart';
import 'widgets/workout_header.dart';
import 'widgets/exercise_card.dart';

class WorkoutPage extends ConsumerStatefulWidget {
  const WorkoutPage({super.key});
  @override
  ConsumerState<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends ConsumerState<WorkoutPage> {
  @override
  void initState() {
    super.initState();
    WakelockPlus.enable(); // keep the screen on in the gym
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  Future<void> _finish() async {
    final w = ref.read(workoutEditorProvider);
    if (w == null) return;
    if (w.completedSets.isEmpty) {
      snack(context, 'Complete at least one set first.');
      return;
    }
    final open =
        w.exercises.expand((e) => e.sets).where((s) => !s.completed && (s.weight != null || s.reps != null)).length;
    if (open > 0) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Finish workout?'),
          content: Text(
              '$open set${open == 1 ? '' : 's'} not marked as done. They will be kept but not counted in statistics.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Keep logging')),
            TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Finish')),
          ],
        ),
      );
      if (ok != true) return;
    }
    ref.read(restTimerProvider.notifier).stop();
    final prs = await ref.read(workoutEditorProvider.notifier).finish();
    refreshAll(ref);
    if (!mounted) return;
    if (prs.isNotEmpty) await showPrDialog(context, prs, ref.read(settingsProvider));
    if (mounted) context.go('/training');
  }

  Future<void> _discard(bool isEdit) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(isEdit ? 'Delete workout?' : 'Discard workout?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: Text(isEdit ? 'Delete' : 'Discard')),
        ],
      ),
    );
    if (ok != true) return;
    ref.read(restTimerProvider.notifier).stop();
    await ref.read(workoutEditorProvider.notifier).discard();
    refreshAll(ref);
    if (mounted) context.go('/training');
  }

  @override
  Widget build(BuildContext context) {
    final w = ref.watch(workoutEditorProvider);
    final editor = ref.read(workoutEditorProvider.notifier);
    if (w == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(icon: Icons.fitness_center, title: 'No workout open'),
      );
    }
    final isEdit = w.status == 'done';
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (isEdit) editor.closeEditor();
            context.canPop() ? context.pop() : context.go('/training');
          },
        ),
        title: InkWell(
          onTap: () async {
            final c = TextEditingController(text: w.name);
            final name = await showDialog<String>(
              context: context,
              builder: (d) => AlertDialog(
                title: const Text('Workout name'),
                content: TextField(controller: c, autofocus: true),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(d), child: const Text('Cancel')),
                  TextButton(onPressed: () => Navigator.pop(d, c.text.trim()), child: const Text('Save')),
                ],
              ),
            );
            if (name != null && name.isNotEmpty) editor.rename(name);
          },
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(w.name, overflow: TextOverflow.ellipsis),
            isEdit
                ? Text('Editing · ${DateFormat.yMMMd().format(w.date)}',
                    style: TextStyle(fontSize: 12, color: context.muted))
                : ElapsedTimer(start: w.startedAt),
          ]),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'discard') _discard(isEdit);
            },
            itemBuilder: (c) =>
                [PopupMenuItem(value: 'discard', child: Text(isEdit ? 'Delete workout' : 'Discard workout'))],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(72, 40)),
              onPressed: _finish,
              child: Text(isEdit ? 'Save' : 'Finish'),
            ),
          ),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 32),
            children: [
              WorkoutHeader(workout: w),
              for (final we in w.exercises) ExerciseCard(key: ValueKey(we.id), workout: w, we: we),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add exercise'),
                onPressed: () async {
                  final ex = await pickExercise(context);
                  if (ex != null) await editor.addExercise(ex);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: w.notes,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(hintText: 'Workout notes'),
                onChanged: editor.setNotes,
              ),
            ],
          ),
        ),
        const RestTimerBar(),
      ]),
    );
  }
}
