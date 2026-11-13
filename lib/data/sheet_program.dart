import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/load_parser.dart';
import 'models.dart';

const sheetProgramName = 'Miklós · Coach plan';

class SheetProgramImport {
  final Program program;
  final List<Exercise> customExercises;

  const SheetProgramImport({
    required this.program,
    required this.customExercises,
  });
}

class _DayBuilder {
  final ProgramDay day;
  final Map<String, ProgramExercise> exercises = {};

  _DayBuilder(this.day);
}

Future<SheetProgramImport> sheetCoachProgram() async {
  final decoded = jsonDecode(await rootBundle.loadString('assets/coach_plans.json'));
  if (decoded is! Map<String, dynamic> || decoded['sheets'] is! List) {
    throw const FormatException('The coach-plan asset has an invalid format.');
  }

  final customExercises = <String, Exercise>{};
  final blocks = <ProgramBlock>[];
  for (final item in decoded['sheets'] as List<dynamic>) {
    if (item is! Map<String, dynamic>) {
      throw const FormatException('A coach-plan worksheet has an invalid format.');
    }
    blocks.add(_parseWorksheet(item, customExercises));
  }
  if (blocks.length != 11) {
    throw FormatException('Expected 11 coach-plan worksheets, found ${blocks.length}.');
  }

  return SheetProgramImport(
    program: Program(
      name: sheetProgramName,
      description: 'Coach plans imported from all 11 worksheets. Completed workout results are not imported.',
      blocks: blocks,
    ),
    customExercises: customExercises.values.toList(),
  );
}

ProgramBlock _parseWorksheet(
  Map<String, dynamic> worksheet,
  Map<String, Exercise> customExercises,
) {
  final name = _text(worksheet['name']);
  final weekCount = worksheet['weeks'];
  final rows = worksheet['rows'];
  if (name.isEmpty || weekCount is! int || weekCount < 1 || weekCount > 5 || rows is! List) {
    throw const FormatException('A coach-plan worksheet is missing its name, weeks, or rows.');
  }

  final days = <int, _DayBuilder>{};
  DateTime? startDate;
  for (var week = 0; week < weekCount; week++) {
    int? activeDay;
    String? activeExerciseId;
    for (final row in rows) {
      if (row is! Map<String, dynamic> || row['weeks'] is! List) {
        throw const FormatException('A coach-plan row has an invalid format.');
      }
      final weekCells = row['weeks'] as List<dynamic>;
      if (week >= weekCells.length || weekCells[week] is! Map<String, dynamic>) {
        throw const FormatException('A coach-plan row is missing a week.');
      }
      final cells = weekCells[week] as Map<String, dynamic>;
      final marker = _dayNumber(_text(cells['name']));
      if (marker != null) {
        activeDay = marker;
        activeExerciseId = null;
        final date = DateTime.tryParse(_text(cells['date']));
        days.putIfAbsent(
          marker,
          () => _DayBuilder(
            ProgramDay(
              name: 'Day $marker',
              weekday: _weekday(_text(cells['weekday']), marker),
              tag: _text(cells['tag']),
              position: marker - 1,
            ),
          ),
        );
        if (week == 0 && startDate == null && date != null) {
          startDate = date;
        }
        continue;
      }

      if (activeDay == null) continue;
      final setCount = _setCount(_text(cells['sets']));
      final setCountNote = _setCountNote(_text(cells['sets']));
      final reps = _text(cells['reps']);
      if (setCount == null || !_validReps(reps)) continue;

      final rawName = _exerciseName(cells);
      if (rawName.isNotEmpty) {
        activeExerciseId = _resolveExerciseId(
          rawName,
          dayNumber: activeDay,
          dayTag: days[activeDay]!.day.tag,
          customExercises: customExercises,
        );
      }
      if (activeExerciseId == null) continue;

      final builder = days[activeDay]!;
      final exercise = builder.exercises.putIfAbsent(
        activeExerciseId,
        () => ProgramExercise(exerciseId: activeExerciseId!),
      );
      exercise.sets.add(_makeSet(
        week: week,
        setCount: setCount,
        setCountNote: setCountNote,
        reps: reps,
        load: _text(cells['load']),
        rpe: _text(cells['rpe']),
        exerciseId: activeExerciseId,
        dayNumber: activeDay,
        exerciseName: rawName,
      ));
    }
  }

  if (days.isEmpty) {
    throw FormatException('Worksheet "$name" does not contain any training days.');
  }

  final programDays = <ProgramDay>[];
  for (final entry in days.entries) {
    final builder = entry.value;
    for (final exercise in builder.exercises.values) {
      for (var week = 0; week < weekCount; week++) {
        final sets = exercise.sets.where((set) => set.weekIndex == week).toList();
        for (var position = 0; position < sets.length; position++) {
          sets[position].position = position;
        }
      }
    }
    builder.day.exercises.addAll(builder.exercises.values);
    programDays.add(builder.day);
  }

  return ProgramBlock(
    name: name,
    startDate: startDate,
    weekCount: weekCount,
    days: programDays,
  );
}

PrescribedSet _makeSet({
  required int week,
  required int setCount,
  required String setCountNote,
  required String reps,
  required String load,
  required String rpe,
  required String exerciseId,
  required int dayNumber,
  required String exerciseName,
}) {
  var prescribedLoad = load.trim();
  var note = '';
  var parsedLoad = parsePrescription(prescribedLoad);
  final ambiguous = prescribedLoad.startsWith('-') ||
      (parsedLoad.weight != null && parsedLoad.weightMax != null && parsedLoad.weightMax! < parsedLoad.weight!) ||
      (exerciseId == 'low_bar_squat' && dayNumber == 3 && prescribedLoad == '5');
  if (ambiguous) {
    note = 'Sheet load omitted: $prescribedLoad';
    prescribedLoad = '';
    parsedLoad = const Prescription();
  }
  if (setCountNote.isNotEmpty) {
    note = _appendNote(note, setCountNote);
  }

  final explicitRpeText = rpe.trim();
  final explicitRpe = explicitRpeText.isEmpty
      ? const Prescription()
      : parsePrescription(
          explicitRpeText.toLowerCase().startsWith('r') ? explicitRpeText : 'R$explicitRpeText',
        );
  final rpeMin = explicitRpe.rpeMin ?? parsedLoad.rpeMin;
  final rpeMax = explicitRpe.rpeMax ?? parsedLoad.rpeMax;
  final tempo =
      RegExp(r'tempo\s*([0-9]+(?:-[0-9]+){1,2})', caseSensitive: false).firstMatch(exerciseName)?.group(1) ?? '';
  final loadType = parsedLoad.isMax
      ? LoadType.max
      : parsedLoad.isPercent
          ? LoadType.pct
          : parsedLoad.weight != null
              ? LoadType.abs
              : rpeMin != null
                  ? LoadType.rpe
                  : LoadType.free;
  final (repsMin, repsMax) = parseReps(reps);
  final isAmrap = reps.trim().toLowerCase() == 'amrap';
  return PrescribedSet(
    weekIndex: week,
    sets: setCount,
    repsMin: repsMin,
    repsMax: repsMax,
    loadType: loadType,
    weight: parsedLoad.weight,
    weightMax: parsedLoad.weightMax,
    rpeMin: rpeMin,
    rpeMax: rpeMax,
    note: note,
    tempo: tempo,
    constant: parsedLoad.isConstant,
    repeatUntil: parsedLoad.isRepeat,
    amrap: isAmrap,
  );
}

String _appendNote(String current, String addition) => current.isEmpty ? addition : '$current · $addition';

String _setCountNote(String raw) {
  final match = RegExp(r'^(\d+)\s*-\s*(\d+)$').firstMatch(raw);
  return match == null ? '' : '${match.group(1)}-${match.group(2)} sets as written';
}

int? _setCount(String raw) {
  if (raw.isEmpty) return 1;
  final match = RegExp(r'^(\d+)(?:\s*-\s*(\d+))?$').firstMatch(raw);
  if (match == null) return null;
  final first = int.parse(match.group(1)!);
  final last = int.tryParse(match.group(2) ?? match.group(1)!);
  if (first < 1 || first > 30 || last == null || last < first || last > 30) return null;
  return first;
}

bool _validReps(String raw) {
  final value = raw.trim().toLowerCase();
  if (value == '?' || value == 'amrap' || value == 'max') return true;
  final match = RegExp(r'^(\d+)(?:\s*-\s*(\d+))?$').firstMatch(value);
  if (match == null) return false;
  final first = int.parse(match.group(1)!);
  final last = int.tryParse(match.group(2) ?? match.group(1)!);
  return first > 0 && first <= 30 && last != null && last > 0 && last <= 30;
}

int? _dayNumber(String name) {
  final match = RegExp(r'^(\d+)\.NAP$', caseSensitive: false).firstMatch(name);
  return match == null ? null : int.tryParse(match.group(1)!);
}

int _weekday(String raw, int dayNumber) {
  return switch (_normalize(raw)) {
    'hetfo' => DateTime.monday,
    'kedd' => DateTime.tuesday,
    'szerda' => DateTime.wednesday,
    'csutortok' => DateTime.thursday,
    'pentek' => DateTime.friday,
    'szombat' => DateTime.saturday,
    'vasarnap' => DateTime.sunday,
    _ => ((dayNumber - 1) % DateTime.daysPerWeek) + 1,
  };
}

String _exerciseName(Map<String, dynamic> cells) {
  final name = _text(cells['name']);
  final alternateName = _text(cells['alternateName']);
  return _normalize(name).startsWith('opc') && alternateName.isNotEmpty ? alternateName : name;
}

String _resolveExerciseId(
  String rawName, {
  required int dayNumber,
  required String dayTag,
  required Map<String, Exercise> customExercises,
}) {
  final normalized = _normalize(rawName);
  if (normalized.startsWith('tempo')) {
    if (dayNumber == 1 || (dayTag.contains('SQ') && !dayTag.contains('BP'))) return 'tempo_squat';
    if (dayNumber == 2 || dayTag.contains('BP')) return 'tempo_bench';
  }

  const aliases = {
    'low bar guggolas': 'low_bar_squat',
    'high bar guggolas': 'high_bar_squat',
    'guggolas': 'low_bar_squat',
    'verseny guggolas': 'comp_squat',
    'fekvenyomas': 'comp_bench',
    'fekvenyomas nem tempo': 'comp_bench',
    'szuk': 'close_grip_bench',
    'szuk fekvenyomas': 'close_grip_bench',
    'larsen fekvenyomas': 'larsen_press',
    'szumo felhuzas': 'sumo_deadlift',
    'sumo felhuzas': 'sumo_deadlift',
    'hagyomanyos felhuzas': 'conv_deadlift',
    'sldl': 'rdl',
    'sl dl': 'rdl',
    'romanian deadlift': 'rdl',
    'lehuzas csigan': 'lat_pulldown',
    'tricepsz letolas': 'tri_pushdown',
    'oldal emeles': 'lateral_raise',
    'lateral raise': 'lateral_raise',
    'hiperhajlitas': 'hyperextension',
    'combfeszito': 'leg_extension',
    'combhajlito': 'ham_curl',
    'gepes nyomas': 'machine_chest_press',
    'gepen nyomas': 'machine_chest_press',
    'dontot pados gepes ny': 'machine_chest_press',
    'egykezes fekvenyomas': 'one_arm_db_bench',
    'mellkastamasztasos evezes': 'chest_supported_row',
    'evezes mellkastamasszal': 'chest_supported_row',
    'francia nyomas': 'ez_skull',
    'tricepsz nyujtas fej folott': 'oh_tri_ext',
    'dontott pados bicepsz': 'incline_curl',
    'hack guggolas': 'hack_squat',
    'gepes tarogatas': 'pec_deck',
    'tarogatas': 'pec_deck',
  };
  final known = aliases[normalized];
  if (known != null) return known;

  final slug = normalized.replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'^_|_$'), '');
  final id = 'sheet_${slug.isEmpty ? 'exercise' : slug}';
  customExercises.putIfAbsent(
    id,
    () => Exercise(
      id: id,
      name: rawName.trim(),
      category: _liftFor(normalized) == null ? 'accessory' : 'main',
      lift: _liftFor(normalized),
      equipment: _equipmentFor(normalized),
      variation: _liftFor(normalized) != null,
      isCustom: true,
    ),
  );
  return id;
}

String? _liftFor(String name) {
  if (name.contains('guggolas') || name.contains('squat')) return Lift.squat;
  if (name.contains('fekvenyomas') || name.contains('bench')) return Lift.bench;
  if (name.contains('felhuzas') || name.contains('deadlift')) return Lift.deadlift;
  return null;
}

String _equipmentFor(String name) {
  if (name.contains('gep') || name.contains('machine')) return 'machine';
  if (name.contains('csiga') || name.contains('kotel') || name.contains('cable')) return 'cable';
  if (name.contains('kezisulyzo') || name.contains('dumbbell')) return 'dumbbell';
  if (name.contains('testsuly') || name.contains('bodyweight')) return 'bodyweight';
  return 'barbell';
}

String _normalize(String value) {
  return value
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ö', 'o')
      .replaceAll('ő', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ü', 'u')
      .replaceAll('ű', 'u')
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .trim();
}

String _text(Object? value) => value is String ? value.trim() : '';
