import 'set_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../data/models.dart';
import '../../../data/settings.dart';
import '../../../domain/plates.dart';
import '../../../providers/providers.dart';

// ─────────────────────────── Exercise card ───────────────────────────

class ExerciseCard extends ConsumerStatefulWidget {
  final Workout workout;
  final WorkoutExercise we;
  const ExerciseCard({super.key, required this.workout, required this.we});
  @override
  ConsumerState<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends ConsumerState<ExerciseCard> {
  bool _showNotes = false;

  @override
  Widget build(BuildContext context) {
    final we = widget.we;
    final settings = ref.watch(settingsProvider);
    final editor = ref.read(workoutEditorProvider.notifier);
    final prev = ref.watch(lastPerformanceProvider(we.exercise.id, widget.workout.id));
    final prevText = prev.maybeWhen(
      data: (sets) => sets.isEmpty
          ? 'No previous data'
          : 'Last: ${sets.take(5).map((s) => '${fmtNum(settings.toDisplay(s.weight ?? 0))}×${s.reps ?? 0}').join(' · ')}${sets.length > 5 ? ' …' : ''}',
      orElse: () => '',
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text(we.exercise.name,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: context.accent)),
            ),
            PopupMenuButton<String>(
              onSelected: (v) async {
                switch (v) {
                  case 'note':
                    setState(() => _showNotes = true);
                  case 'tempo':
                    final c = TextEditingController(text: we.tempo);
                    final t = await showDialog<String>(
                      context: context,
                      builder: (d) => AlertDialog(
                        title: const Text('Tempo'),
                        content: TextField(
                            controller: c, autofocus: true, decoration: const InputDecoration(hintText: 'e.g. 4-2-0')),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(d), child: const Text('Cancel')),
                          TextButton(onPressed: () => Navigator.pop(d, c.text.trim()), child: const Text('Save')),
                        ],
                      ),
                    );
                    if (t != null) editor.setTempo(we.id, t);
                  case 'plates':
                    final top = we.sets.map((s) => (s.weight ?? 0).toDouble()).fold<double>(0, (a, b) => a > b ? a : b);
                    if (context.mounted) _plateSheet(context, top, settings);
                  case 'up':
                    editor.moveExercise(we.id, -1);
                  case 'down':
                    editor.moveExercise(we.id, 1);
                  case 'remove':
                    editor.removeExercise(we.id);
                }
              },
              itemBuilder: (c) => const [
                PopupMenuItem(value: 'note', child: Text('Add note')),
                PopupMenuItem(value: 'tempo', child: Text('Set tempo')),
                PopupMenuItem(value: 'plates', child: Text('Plate calculator')),
                PopupMenuItem(value: 'up', child: Text('Move up')),
                PopupMenuItem(value: 'down', child: Text('Move down')),
                PopupMenuItem(value: 'remove', child: Text('Remove exercise')),
              ],
            ),
          ]),
          if (prevText.isNotEmpty) Text(prevText, style: TextStyle(color: context.muted, fontSize: 12)),
          if (we.tempo.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('Tempo ${we.tempo}',
                  style: TextStyle(color: context.accent, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          if (_showNotes || we.notes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 4),
              child: TextFormField(
                initialValue: we.notes,
                minLines: 1,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Exercise note', isDense: true),
                onChanged: (v) => editor.setExerciseNotes(we.id, v),
              ),
            ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Row(children: [
              const SizedBox(width: 44),
              _head(context, settings.unitLabel.toUpperCase(), 3),
              _head(context, 'REPS', 2),
              _head(context, settings.rpeScale.toUpperCase(), 2),
              const SizedBox(width: 52),
            ]),
          ),
          for (var i = 0; i < we.sets.length; i++)
            SetRow(key: ValueKey(we.sets[i].id), workout: widget.workout, we: we, index: i),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add set'),
                onPressed: () => editor.addSet(we.id),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _head(BuildContext c, String t, int flex) => Expanded(
        flex: flex,
        child: Center(child: Text(t, style: TextStyle(color: c.muted, fontSize: 11, fontWeight: FontWeight.w700))),
      );

  void _plateSheet(BuildContext context, double topKg, AppSettings s) {
    final c = TextEditingController(text: topKg > 0 ? fmtNum(topKg, decimals: 2) : '');
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          final kg = parseNum(c.text);
          final plates = kg == null ? null : platesPerSide(target: kg, bar: s.barKg);
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + MediaQuery.of(ctx).viewInsets.bottom),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Plate calculator', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              TextField(
                controller: c,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Total weight (kg)', helperText: 'Bar: ${fmtNum(s.barKg)} kg'),
                onChanged: (_) => setS(() {}),
              ),
              const SizedBox(height: 16),
              if (kg == null)
                const Text('Enter a weight')
              else if (plates == null)
                Text('Not possible with standard plates (1.25 kg smallest).', style: TextStyle(color: context.muted))
              else if (plates.isEmpty)
                const Text('Empty bar')
              else ...[
                Text('Per side', style: TextStyle(color: context.muted)),
                const SizedBox(height: 4),
                Text(plates.map((p) => fmtNum(p, decimals: 2)).join('  +  '),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              ],
            ]),
          );
        },
      ),
    );
  }
}
