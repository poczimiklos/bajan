import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../data/models.dart';
import '../../../domain/load_parser.dart';
import 'week_selector.dart';

const weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

class ProgramEditor extends StatelessWidget {
  final ProgramBlock block;
  final List<ProgramDay> days;
  final ProgramDay day;
  final int week;
  final List<Exercise> exercises;
  final String unit;
  final ValueChanged<int> onSelectWeek;
  final ValueChanged<ProgramDay> onSelectDay;
  final VoidCallback onAddDay;
  final ValueChanged<String> onDayAction;
  final VoidCallback onAddExercise;
  final ValueChanged<ProgramExercise> onChooseExercise;
  final ValueChanged<ProgramExercise> onDeleteExercise;
  final void Function(ProgramExercise, PrescribedSet) onAddSet;
  final void Function(ProgramExercise, PrescribedSet) onDeleteSet;
  final VoidCallback onSave;
  final VoidCallback onStart;

  const ProgramEditor({
    super.key,
    required this.block,
    required this.days,
    required this.day,
    required this.week,
    required this.exercises,
    required this.unit,
    required this.onSelectWeek,
    required this.onSelectDay,
    required this.onAddDay,
    required this.onDayAction,
    required this.onAddExercise,
    required this.onChooseExercise,
    required this.onDeleteExercise,
    required this.onAddSet,
    required this.onDeleteSet,
    required this.onSave,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final exerciseNames = {
      for (final exercise in exercises) exercise.id: exercise.nameHu.isNotEmpty ? exercise.nameHu : exercise.name,
    };
    final exerciseLifts = {for (final exercise in exercises) exercise.id: exercise.lift};

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionTitle('Week'),
      WeekSelector(weekCount: block.weekCount, selected: week, onSelect: onSelectWeek),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (var index = 0; index < days.length; index++)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_daySelectorLabel(index, days[index], exerciseLifts)),
                      selected: days[index].id == day.id,
                      onSelected: (_) => onSelectDay(days[index]),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          onPressed: onAddDay,
          tooltip: 'Add training day',
          icon: const Icon(Icons.add),
        ),
      ]),
      const SizedBox(height: 8),
      AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                '${weekdayNames[day.weekday - 1]} · ${day.name}',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              if (day.tag.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(day.tag, style: TextStyle(color: context.accent, fontWeight: FontWeight.w700)),
              ],
            ]),
          ),
          PopupMenuButton<String>(
            onSelected: onDayAction,
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit training day')),
              PopupMenuItem(value: 'delete', child: Text('Delete training day')),
            ],
          ),
        ]),
      ),
      const SizedBox(height: 12),
      if (day.exercises.isEmpty)
        AppCard(
          child: Text(
            'No exercises in this day yet. Add one to start building the plan.',
            style: TextStyle(color: context.muted),
          ),
        )
      else
        for (var index = 0; index < day.exercises.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ProgramExerciseEditor(
              exercise: day.exercises[index],
              index: index,
              week: week,
              unit: unit,
              exerciseNames: exerciseNames,
              onChooseExercise: () => onChooseExercise(day.exercises[index]),
              onDeleteExercise: () => onDeleteExercise(day.exercises[index]),
              onAddSet: () {
                final set = PrescribedSet(
                  weekIndex: week,
                  sets: 1,
                  repsMin: 5,
                  repsMax: 5,
                  position: day.exercises[index].forWeek(week).length,
                );
                onAddSet(day.exercises[index], set);
              },
              onDeleteSet: (set) => onDeleteSet(day.exercises[index], set),
              onSave: onSave,
            ),
          ),
      const SizedBox(height: 4),
      OutlinedButton.icon(
        onPressed: onAddExercise,
        icon: const Icon(Icons.add),
        label: const Text('Add exercise'),
      ),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: day.hasWork(week) ? onStart : null,
          icon: const Icon(Icons.play_arrow),
          label: Text('Start Day ${days.indexOf(day) + 1} · Week ${week + 1}'),
        ),
      ),
    ]);
  }
}

class ProgramExerciseEditor extends StatelessWidget {
  final ProgramExercise exercise;
  final int index;
  final int week;
  final String unit;
  final Map<String, String> exerciseNames;
  final VoidCallback onChooseExercise;
  final VoidCallback onDeleteExercise;
  final VoidCallback onAddSet;
  final ValueChanged<PrescribedSet> onDeleteSet;
  final VoidCallback onSave;

  const ProgramExerciseEditor({
    super.key,
    required this.exercise,
    required this.index,
    required this.week,
    required this.unit,
    required this.exerciseNames,
    required this.onChooseExercise,
    required this.onDeleteExercise,
    required this.onAddSet,
    required this.onDeleteSet,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final sets = exercise.forWeek(week);
    final title = exerciseNames[exercise.exerciseId] ?? exercise.exerciseId;
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.accent.withValues(alpha: 0.12),
              border: Border.all(color: context.accent.withValues(alpha: 0.55)),
            ),
            child: Text(
              '${index + 1}'.padLeft(2, '0'),
              style: TextStyle(color: context.accent, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              onTap: onChooseExercise,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.unfold_more, size: 18, color: context.accent),
                ]),
              ),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') onDeleteExercise();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'delete', child: Text('Remove exercise')),
            ],
            icon: const Icon(Icons.more_vert),
          ),
        ]),
        if (sets.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('No sets prescribed for this week.', style: TextStyle(color: context.muted)),
          ),
        for (var setIndex = 0; setIndex < sets.length; setIndex++)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _SetEditorRow(
              set: sets[setIndex],
              ordinal: setIndex + 1,
              unit: unit,
              onDelete: () => onDeleteSet(sets[setIndex]),
              onSave: onSave,
            ),
          ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: onAddSet,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add set'),
        ),
      ]),
    );
  }
}

class _SetEditorRow extends StatelessWidget {
  final PrescribedSet set;
  final int ordinal;
  final String unit;
  final VoidCallback onDelete;
  final VoidCallback onSave;

  const _SetEditorRow({
    required this.set,
    required this.ordinal,
    required this.unit,
    required this.onDelete,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.fieldBg.withValues(alpha: 0.56),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
      ),
      child: Column(children: [
        Row(children: [
          Expanded(
            child: Text(
              'SET $ordinal',
              style: TextStyle(
                color: context.accent,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onDelete,
            tooltip: 'Delete set',
            icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
          ),
        ]),
        Row(children: [
          SizedBox(
            width: 56,
            child: _InlineField(
              key: ValueKey('${set.id}-sets'),
              label: 'SETS',
              value: '${set.sets}',
              keyboardType: const TextInputType.numberWithOptions(signed: false),
              onChanged: (value) {
                final parsed = int.tryParse(value);
                if (parsed != null && parsed > 0) set.sets = parsed.clamp(1, 30);
              },
              onSave: onSave,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 74,
            child: _InlineField(
              key: ValueKey('${set.id}-reps'),
              label: 'REPS',
              value: set.amrap ? 'AMRAP' : set.repsText,
              keyboardType: const TextInputType.numberWithOptions(signed: true),
              onChanged: (value) {
                if (value.trim().toUpperCase() == 'AMRAP') {
                  set
                    ..amrap = true
                    ..repsMin = null
                    ..repsMax = null;
                } else {
                  final (minimum, maximum) = parseReps(value);
                  set
                    ..amrap = false
                    ..repsMin = minimum
                    ..repsMax = maximum;
                }
              },
              onSave: onSave,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _InlineField(
              key: ValueKey('${set.id}-load'),
              label: 'LOAD ($unit)',
              value: _loadText(set, unit),
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              onChanged: (value) => _applyLoad(set, value, unit),
              onSave: onSave,
            ),
          ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          SizedBox(
            width: 82,
            child: _InlineField(
              key: ValueKey('${set.id}-rpe'),
              label: 'RPE',
              value: _rpeText(set),
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
              onChanged: (value) => _applyRpe(set, value),
              onSave: onSave,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _InlineField(
              key: ValueKey('${set.id}-note'),
              label: 'NOTES',
              value: set.note,
              keyboardType: TextInputType.text,
              onChanged: (value) => set.note = value,
              onSave: onSave,
            ),
          ),
        ]),
      ]),
    );
  }
}

class _InlineField extends StatelessWidget {
  final String label;
  final String value;
  final TextInputType keyboardType;
  final ValueChanged<String> onChanged;
  final VoidCallback onSave;

  const _InlineField({
    super.key,
    required this.label,
    required this.value,
    required this.keyboardType,
    required this.onChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) onSave();
      },
      child: TextFormField(
        initialValue: value,
        onChanged: onChanged,
        keyboardType: keyboardType,
        textInputAction: TextInputAction.next,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        decoration: InputDecoration(labelText: label, isDense: true),
      ),
    );
  }
}

String _loadText(PrescribedSet set, String unit) {
  if (set.loadType == LoadType.max) return 'max';
  if (set.loadType == LoadType.linear) {
    return set.weight == null ? '' : 'last +${_formatWeight(set.weight!, unit)}';
  }
  if (set.loadType == LoadType.pct) {
    return set.weight == null ? '' : '${_formatNumber(set.weight!)}%';
  }
  if (set.loadType != LoadType.abs || set.weight == null) return '';
  final minimum = _formatWeight(set.weight!, unit);
  final maximum = set.weightMax == null ? '' : '-${_formatWeight(set.weightMax!, unit)}';
  return '$minimum$maximum';
}

String _rpeText(PrescribedSet set) {
  if (set.rpeMin == null) return '';
  final minimum = _formatNumber(set.rpeMin!);
  if (set.rpeMax == null || set.rpeMax == set.rpeMin) return minimum;
  return '$minimum-${_formatNumber(set.rpeMax!)}';
}

void _applyLoad(PrescribedSet set, String raw, String unit) {
  final value = raw.trim();
  final rpeMin = set.rpeMin;
  final rpeMax = set.rpeMax;
  if (value.isEmpty) {
    set
      ..loadType = LoadType.free
      ..weight = null
      ..weightMax = null
      ..rpeMin = rpeMin
      ..rpeMax = rpeMax;
    return;
  }

  if (value.toLowerCase().startsWith('last')) {
    final amount = parseNum(value.replaceAll(RegExp(r'[^0-9.,]'), ''));
    set
      ..loadType = LoadType.linear
      ..weight = amount == null ? null : _toKg(amount, unit)
      ..weightMax = null
      ..rpeMin = rpeMin
      ..rpeMax = rpeMax;
    return;
  }

  final parsed = parsePrescription(value);
  final weight = parsed.weight == null || parsed.isPercent ? parsed.weight : _toKg(parsed.weight!, unit);
  final weightMax = parsed.weightMax == null || parsed.isPercent ? parsed.weightMax : _toKg(parsed.weightMax!, unit);
  set
    ..loadType = parsed.isMax
        ? LoadType.max
        : parsed.isPercent
            ? LoadType.pct
            : weight != null
                ? LoadType.abs
                : parsed.rpeMin != null
                    ? LoadType.rpe
                    : LoadType.free
    ..weight = weight
    ..weightMax = weightMax
    ..constant = parsed.isConstant
    ..repeatUntil = parsed.isRepeat
    ..rpeMin = parsed.rpeMin ?? rpeMin
    ..rpeMax = parsed.rpeMax ?? rpeMax;
}

void _applyRpe(PrescribedSet set, String raw) {
  final value = raw.trim().toLowerCase().replaceFirst(RegExp(r'^r'), '');
  if (value.isEmpty) {
    set
      ..rpeMin = null
      ..rpeMax = null;
    if (set.loadType == LoadType.rpe) set.loadType = LoadType.free;
    return;
  }
  final parsed = parsePrescription('R$value');
  set
    ..rpeMin = parsed.rpeMin
    ..rpeMax = parsed.rpeMax;
  if (parsed.rpeMin != null && set.loadType == LoadType.free) {
    set.loadType = LoadType.rpe;
  }
}

double _toKg(double value, String unit) => unit == 'lb' ? value / 2.2046226218 : value;

String _formatWeight(double value, String unit) => _formatNumber(unit == 'lb' ? value * 2.2046226218 : value);

String _formatNumber(double value) => value == value.roundToDouble() ? value.toStringAsFixed(0) : '$value';

String _daySelectorLabel(int index, ProgramDay day, Map<String, String?> exerciseLifts) {
  final dayNumber = index + 1;
  final name = day.name.trim();
  final focus = _dayFocus(day, exerciseLifts);
  if (focus.isNotEmpty) return 'Day $dayNumber · $focus · $name';
  if (name.toLowerCase() == 'day $dayNumber') {
    return 'Day $dayNumber';
  }
  return 'Day $dayNumber · $name';
}

String _dayFocus(ProgramDay day, Map<String, String?> exerciseLifts) {
  final tag = day.tag.toUpperCase();
  if (tag.contains('SQ')) return 'Squat';
  if (tag.contains('BP')) return 'Bench';
  if (tag.contains('DL')) return 'Deadlift';
  for (final exercise in day.exercises) {
    switch (exerciseLifts[exercise.exerciseId]) {
      case Lift.squat:
        return 'Squat';
      case Lift.bench:
        return 'Bench';
      case Lift.deadlift:
        return 'Deadlift';
    }
  }
  return '';
}
