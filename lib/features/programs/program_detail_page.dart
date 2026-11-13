import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/models.dart';
import '../../providers/providers.dart';
import '../training/widgets/exercise_picker.dart';
import '../training/start_workout.dart';
import 'widgets/block_card.dart';
import 'widgets/block_selector.dart';
import 'widgets/day_card.dart';
import 'widgets/program_overview.dart';
import 'widgets/sets_editor.dart';
import 'widgets/week_selector.dart';

class ProgramDetailPage extends ConsumerStatefulWidget {
  final String programId;
  const ProgramDetailPage({super.key, required this.programId});
  @override
  ConsumerState<ProgramDetailPage> createState() => _ProgramDetailPageState();
}

class _ProgramDetailPageState extends ConsumerState<ProgramDetailPage> {
  int _block = 0;
  int _week = 0;

  Future<void> _save(Program p) async {
    await ref.read(programRepoProvider).save(p);
    ref.invalidate(programDetailProvider(widget.programId));
    refreshAll(ref);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(programDetailProvider(widget.programId));
    final settings = ref.watch(settingsProvider);
    final exercises = ref.watch(exercisesProvider).value ?? const <Exercise>[];
    final exName = {for (final e in exercises) e.id: e.name};

    return AsyncView<Program?>(
      value: async,
      onRetry: () => ref.invalidate(programDetailProvider(widget.programId)),
      data: (program) {
        if (program == null) {
          return Scaffold(appBar: AppBar(), body: const EmptyState(icon: Icons.search_off, title: 'Program not found'));
        }
        if (program.blocks.isEmpty) program.blocks.add(ProgramBlock(name: 'Block 1', weekCount: 4));
        _block = _block.clamp(0, program.blocks.length - 1);
        final block = program.blocks[_block];
        _week = _week.clamp(0, block.weekCount - 1);
        final isActive = settings.activeBlockId == block.id;
        final days = [...block.days]..sort((a, b) => a.weekday.compareTo(b.weekday));

        return Scaffold(
          appBar: AppBar(
            title: Text(program.name, overflow: TextOverflow.ellipsis),
            actions: [
              PopupMenuButton<String>(
                onSelected: (v) => _programAction(v, program),
                itemBuilder: (c) => const [
                  PopupMenuItem(value: 'rename', child: Text('Rename program')),
                  PopupMenuItem(value: 'duplicate', child: Text('Duplicate program')),
                  PopupMenuItem(value: 'delete', child: Text('Delete program')),
                ],
              ),
            ],
          ),
          body: ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 32), children: [
            if (program.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(program.description, style: TextStyle(color: context.muted)),
              ),
            ProgramOverview(block: block, days: days, exerciseNames: exName),
            const SizedBox(height: 12),
            // ── blocks ──
            BlockSelector(
              blocks: program.blocks,
              selected: _block,
              onSelect: (i) => setState(() {
                _block = i;
                _week = 0;
              }),
              onAdd: () async {
                program.blocks.add(ProgramBlock(name: 'Block ${program.blocks.length + 1}', weekCount: 4));
                setState(() => _block = program.blocks.length - 1);
                await _save(program);
              },
            ),
            BlockCard(
              block: block,
              isActive: isActive,
              onActivate: () => _activate(program, block),
              onNextBlock: () => _nextBlock(program, block),
              onSettings: () => _blockSettings(program, block),
            ),
            // ── weeks ──
            const SectionTitle('Week'),
            WeekSelector(weekCount: block.weekCount, selected: _week, onSelect: (w) => setState(() => _week = w)),
            // ── days ──
            for (final d in days)
              DayCard(
                day: d,
                week: _week,
                exerciseNames: exName,
                onAction: (v) => _dayAction(v, program, block, d),
                onEditSets: (pe) => _editSets(program, block, d, pe, exName[pe.exerciseId] ?? pe.exerciseId),
                onAddExercise: () async {
                  final ex = await pickExercise(context);
                  if (ex == null) return;
                  d.exercises.add(ProgramExercise(exerciseId: ex.id, sets: [
                    PrescribedSet(weekIndex: _week, sets: 3, repsMin: 5, repsMax: 5),
                  ]));
                  await _save(program);
                },
                onStart: () => StartWorkout.fromDay(context, ref, program: program, block: block, day: d, week: _week),
              ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add training day'),
              onPressed: () => _addDay(program, block),
            ),
          ]),
        );
      },
    );
  }

  // ── actions ──
  Future<void> _programAction(String v, Program p) async {
    switch (v) {
      case 'rename':
        final name = await _askText('Rename program', p.name);
        if (name != null && name.isNotEmpty) {
          p.name = name;
          await _save(p);
        }
      case 'duplicate':
        final copy = ref.read(programRepoProvider).duplicate(p);
        await ref.read(programRepoProvider).save(copy);
        refreshAll(ref);
        if (mounted) context.pushReplacement('/program/${copy.id}');
      case 'delete':
        final ok = await _confirm('Delete "${p.name}"?', 'Logged workouts are kept.');
        if (ok != true) return;
        final active = ref.read(settingsProvider).activeBlockId;
        if (p.blocks.any((b) => b.id == active)) {
          await ref.read(settingsProvider.notifier).update((s) => s.copyWith(activeBlockId: null));
        }
        await ref.read(programRepoProvider).delete(p.id);
        refreshAll(ref);
        if (mounted) context.pop();
    }
  }

  Future<void> _activate(Program p, ProgramBlock b) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: b.startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Block start date (week 1)',
    );
    if (picked == null) return;
    b.startDate = picked;
    await ref.read(settingsProvider.notifier).update((s) => s.copyWith(activeBlockId: b.id));
    await _save(p);
    if (mounted) snack(context, '${b.name} is now your active block.');
  }

  Future<void> _nextBlock(Program p, ProgramBlock b) async {
    final c = TextEditingController(text: '5');
    final inc = await showDialog<double>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Create next block'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Copies this block and adds a fixed amount to every absolute weight.'),
          const SizedBox(height: 12),
          TextField(
            controller: c,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Add (kg)'),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(d, parseNum(c.text) ?? 0), child: const Text('Create')),
        ],
      ),
    );
    if (inc == null) return;
    final start = b.startDate?.add(Duration(days: b.weekCount * 7));
    final nb = ref.read(programRepoProvider).duplicateBlock(b, start: start);
    nb.name = 'Block ${p.blocks.length + 1}';
    for (final d in nb.days) {
      for (final e in d.exercises) {
        for (final s in e.sets) {
          if (s.loadType == LoadType.abs && s.weight != null) {
            s.weight = s.weight! + inc;
            if (s.weightMax != null) s.weightMax = s.weightMax! + inc;
          }
        }
      }
    }
    p.blocks.add(nb);
    setState(() {
      _block = p.blocks.length - 1;
      _week = 0;
    });
    await _save(p);
  }

  Future<void> _blockSettings(Program p, ProgramBlock b) async {
    final name = TextEditingController(text: b.name);
    final weeks = TextEditingController(text: '${b.weekCount}');
    final result = await showDialog<String>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Block settings'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
          const SizedBox(height: 12),
          TextField(
              controller: weeks,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Weeks')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, 'delete'), child: const Text('Delete block')),
          TextButton(onPressed: () => Navigator.pop(d), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(d, 'save'), child: const Text('Save')),
        ],
      ),
    );
    if (result == 'save') {
      b.name = name.text.trim().isEmpty ? b.name : name.text.trim();
      b.weekCount = (int.tryParse(weeks.text) ?? b.weekCount).clamp(1, 30);
      await _save(p);
    } else if (result == 'delete') {
      if (p.blocks.length == 1) {
        if (mounted) snack(context, 'A program needs at least one block.');
        return;
      }
      p.blocks.remove(b);
      setState(() => _block = 0);
      await _save(p);
    }
  }

  Future<void> _addDay(Program p, ProgramBlock b) async {
    final name = TextEditingController(text: 'Day ${b.days.length + 1}');
    final tag = TextEditingController();
    var weekday = DateTime.monday;
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => StatefulBuilder(
        builder: (d, setS) => AlertDialog(
          title: const Text('New training day'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: weekday,
              decoration: const InputDecoration(labelText: 'Weekday'),
              items: [for (var i = 1; i <= 7; i++) DropdownMenuItem(value: i, child: Text(weekdayNames[i - 1]))],
              onChanged: (v) => setS(() => weekday = v ?? 1),
            ),
            const SizedBox(height: 12),
            TextField(controller: tag, decoration: const InputDecoration(labelText: 'Tag (optional, e.g. SQ1 BP2)')),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(d, true), child: const Text('Add')),
          ],
        ),
      ),
    );
    if (ok != true) return;
    b.days.add(ProgramDay(
        name: name.text.trim().isEmpty ? 'Day' : name.text.trim(),
        weekday: weekday,
        tag: tag.text.trim().toUpperCase()));
    await _save(p);
  }

  Future<void> _dayAction(String v, Program p, ProgramBlock b, ProgramDay d) async {
    if (v == 'delete') {
      if (await _confirm('Delete ${d.name}?', 'Its prescriptions are removed from this block.') == true) {
        b.days.remove(d);
        await _save(p);
      }
      return;
    }
    final name = TextEditingController(text: d.name);
    final tag = TextEditingController(text: d.tag);
    var weekday = d.weekday;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setS) => AlertDialog(
          title: const Text('Edit day'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: weekday,
              decoration: const InputDecoration(labelText: 'Weekday'),
              items: [for (var i = 1; i <= 7; i++) DropdownMenuItem(value: i, child: Text(weekdayNames[i - 1]))],
              onChanged: (x) => setS(() => weekday = x ?? 1),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tag,
              decoration:
                  const InputDecoration(labelText: 'Tag', helperText: 'SQ1 = primary squat, SQ2 = secondary squat, …'),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Save')),
          ],
        ),
      ),
    );
    if (ok != true) return;
    d.name = name.text.trim().isEmpty ? d.name : name.text.trim();
    d.weekday = weekday;
    d.tag = tag.text.trim().toUpperCase();
    await _save(p);
  }

  Future<void> _editSets(Program p, ProgramBlock b, ProgramDay d, ProgramExercise pe, String title) async {
    final result = await showModalBottomSheet<SheetResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (c) => SetsEditor(title: title, week: _week, weekCount: b.weekCount, initial: pe.forWeek(_week)),
    );
    if (result == null) return;
    if (result.removeExercise) {
      d.exercises.remove(pe);
      await _save(p);
      return;
    }
    pe.sets.removeWhere((s) => s.weekIndex == _week);
    for (var i = 0; i < result.sets.length; i++) {
      result.sets[i].position = i;
      pe.sets.add(result.sets[i]);
    }
    if (result.propagate) {
      pe.sets.removeWhere((s) => s.weekIndex > _week);
      for (var w = _week + 1; w < b.weekCount; w++) {
        for (final s in result.sets) {
          final n = s.copyForWeek(w);
          if (n.loadType == LoadType.abs && n.weight != null) {
            n.weight = n.weight! + result.step * (w - _week);
            if (n.weightMax != null) n.weightMax = n.weightMax! + result.step * (w - _week);
          }
          pe.sets.add(n);
        }
      }
    }
    await _save(p);
  }

  Future<String?> _askText(String title, String initial) {
    final c = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(title),
        content: TextField(controller: c, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(d, c.text.trim()), child: const Text('Save')),
        ],
      ),
    );
  }

  Future<bool?> _confirm(String title, String msg) => showDialog<bool>(
        context: context,
        builder: (d) => AlertDialog(
          title: Text(title),
          content: Text(msg),
          actions: [
            TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(d, true), child: const Text('Delete')),
          ],
        ),
      );
}
