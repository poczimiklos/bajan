import 'models.dart';
import 'repositories/exercise_repository.dart';

const block1ProgramName = 'e2.0 - Block1';
const block1ImportPreferenceKey = 'block1_program_imported_v1';

class _WeekPrescription {
  const _WeekPrescription(this.sets, this.reps, {this.load = '', this.note = ''});

  final int sets;
  final String reps;
  final String load;
  final String note;
}

class _ImportedExercise {
  const _ImportedExercise(this.name, this.weeks);

  final String name;
  final List<List<_WeekPrescription>> weeks;
}

class _ImportedDay {
  const _ImportedDay(this.name, this.weekday, this.tag, this.exercises);

  final String name;
  final int weekday;
  final String tag;
  final List<_ImportedExercise> exercises;
}

const _days = <_ImportedDay>[
  _ImportedDay('Kedd', DateTime.tuesday, 'SQ1 BP1', [
    _ImportedExercise('Tempo 4-2-0', [
      [_WeekPrescription(1, '2', load: '190'), _WeekPrescription(1, '2', load: '200')],
      [_WeekPrescription(1, '2', load: '195'), _WeekPrescription(1, '2', load: '205')],
      [_WeekPrescription(1, '2', load: '200'), _WeekPrescription(1, '2', load: '210')],
      [_WeekPrescription(1, '2', load: '205'), _WeekPrescription(1, '2', load: '215')],
      [_WeekPrescription(1, '2'), _WeekPrescription(1, '2')],
    ]),
    _ImportedExercise('Low bar guggolás', [
      [_WeekPrescription(3, '5', load: '185')],
      [_WeekPrescription(3, '5', load: '190')],
      [_WeekPrescription(3, '5', load: '192,5')],
      [_WeekPrescription(3, '5', load: '195')],
      [_WeekPrescription(3, '5')],
    ]),
    _ImportedExercise('bench', [
      [_WeekPrescription(4, '5', load: '105')],
      [_WeekPrescription(4, '5', load: '107,5')],
      [_WeekPrescription(4, '5', load: '110')],
      [_WeekPrescription(4, '5', load: '112,5')],
      [_WeekPrescription(4, '5')],
    ]),
    _ImportedExercise('lehuzas magam melle', [
      [_WeekPrescription(2, '6', load: '65')],
      [_WeekPrescription(2, '8', load: '50', note: 'kinti gepen')],
      [_WeekPrescription(2, '7', load: '65')],
      [_WeekPrescription(2, '7', load: '65')],
      [_WeekPrescription(2, '7')],
    ]),
    _ImportedExercise('tarogatas', [
      [_WeekPrescription(2, '8-10', load: '25', note: 'döntötpad')],
      [_WeekPrescription(2, '8-10', load: '120', note: 'hoist')],
      [_WeekPrescription(2, '8-10', load: '120', note: 'hoist')],
      [_WeekPrescription(2, '8-10', load: '20', note: 'kinti')],
      [_WeekPrescription(2, '8-10')],
    ]),
    _ImportedExercise('b francia', [
      [_WeekPrescription(2, '8', load: '45')],
      [_WeekPrescription(2, '8', load: '45')],
      [_WeekPrescription(2, '8', load: '45')],
      [_WeekPrescription(2, '6', load: '40', note: 'pakolos francival')],
      [_WeekPrescription(2, '8')],
    ]),
    _ImportedExercise('oldal emeles', [
      [_WeekPrescription(2, '8-10', load: '18-19')],
      [_WeekPrescription(2, '8', load: '19')],
      [_WeekPrescription(2, '8', load: '19')],
      [_WeekPrescription(2, '8', load: '18')],
      [_WeekPrescription(2, '8')],
    ]),
  ]),
  _ImportedDay('Csütörtök', DateTime.thursday, 'BP1 DL1', [
    _ImportedExercise('bench', [
      [_WeekPrescription(3, '3', load: '120')],
      [_WeekPrescription(3, '3', load: '122,5')],
      [_WeekPrescription(3, '3', load: '125')],
      [_WeekPrescription(3, '3', load: '127,5')],
      [_WeekPrescription(3, '3')],
    ]),
    _ImportedExercise('deadlift', [
      [
        _WeekPrescription(1, '2', load: '225'),
        _WeekPrescription(1, '1', load: '235'),
        _WeekPrescription(3, '4', load: '195'),
      ],
      [
        _WeekPrescription(1, '2', load: '230'),
        _WeekPrescription(1, '1', load: '240'),
        _WeekPrescription(3, '4', load: '197,5-200'),
      ],
      [
        _WeekPrescription(1, '2', load: '235'),
        _WeekPrescription(1, '1', load: '245'),
        _WeekPrescription(3, '4', load: '205'),
      ],
      [
        _WeekPrescription(1, '2', load: '240'),
        _WeekPrescription(1, '1', load: '250'),
        _WeekPrescription(3, '4', load: '207,5'),
      ],
      [
        _WeekPrescription(1, '2'),
        _WeekPrescription(1, '1'),
        _WeekPrescription(3, '4'),
      ],
    ]),
    _ImportedExercise('szeles lehuzas', [
      [_WeekPrescription(2, '6-12', note: 'huzodzkodas')],
      [_WeekPrescription(2, '6-12', note: 'huzodzkodas')],
      [_WeekPrescription(2, '7', load: 'm+5', note: 'benedekfele')],
      [_WeekPrescription(2, '6-12', load: 'max')],
      [_WeekPrescription(2, '6-12')],
    ]),
    _ImportedExercise('kalapacsb', [
      [_WeekPrescription(2, '6-12', load: '26')],
      [_WeekPrescription(2, '6-12', load: '26')],
      [_WeekPrescription(2, '7-8', load: '28-26')],
      [_WeekPrescription(2, '8', load: '28')],
      [_WeekPrescription(2, '6-12')],
    ]),
    _ImportedExercise('oldalemeles', [
      [_WeekPrescription(2, '8', load: '19')],
      [_WeekPrescription(2, '8', load: '19')],
      [_WeekPrescription(2, '8', load: '19')],
      [_WeekPrescription(2, '8', load: '19')],
      [_WeekPrescription(2, '8')],
    ]),
  ]),
  _ImportedDay('Szombat', DateTime.saturday, 'SQ1 BP1 DL1', [
    _ImportedExercise('squat', [
      [
        _WeekPrescription(1, '2', load: '195'),
        _WeekPrescription(1, '2', load: '205'),
        _WeekPrescription(2, '5', load: '185'),
      ],
      [
        _WeekPrescription(1, '2', load: '200'),
        _WeekPrescription(1, '2', load: '210'),
        _WeekPrescription(2, '5', load: '190'),
      ],
      [
        _WeekPrescription(1, '2', load: '205'),
        _WeekPrescription(1, '2', load: '215'),
        _WeekPrescription(2, '5', load: '195'),
      ],
      [_WeekPrescription(4, '2'), _WeekPrescription(2, '5')],
      [_WeekPrescription(4, '2'), _WeekPrescription(2, '5')],
    ]),
    _ImportedExercise('bench', [
      [_WeekPrescription(3, '1', load: '125')],
      [_WeekPrescription(3, '1', load: '127,5')],
      [_WeekPrescription(3, '1', load: '130')],
      [_WeekPrescription(3, '1')],
      [_WeekPrescription(3, '1')],
    ]),
    _ImportedExercise('deadlift', [
      [_WeekPrescription(1, '5', load: '210'), _WeekPrescription(3, '5', load: '192,5')],
      [_WeekPrescription(1, '5', load: '220'), _WeekPrescription(3, '5', load: '200')],
      [_WeekPrescription(1, '5', load: '225'), _WeekPrescription(3, '5', load: '200')],
      [_WeekPrescription(1, '5'), _WeekPrescription(3, '5')],
      [_WeekPrescription(1, '5'), _WeekPrescription(3, '5')],
    ]),
    _ImportedExercise('chest press alva', [
      [_WeekPrescription(2, '8-7', load: '18-17')],
      [_WeekPrescription(2, '7-6', load: '18-17')],
      [_WeekPrescription(2, '8-5', load: '18-17')],
      [_WeekPrescription(2, '8-7')],
      [_WeekPrescription(2, '8-7')],
    ]),
    _ImportedExercise('evezes szeles', [
      [_WeekPrescription(2, '6', load: '65')],
      [_WeekPrescription(2, '6', load: '65')],
      [_WeekPrescription(2, '8', load: '65')],
      [_WeekPrescription(2, '6')],
      [_WeekPrescription(2, '6')],
    ]),
    _ImportedExercise('hatsoval', [
      [_WeekPrescription(2, '8-10', load: '55')],
      [_WeekPrescription(2, '8-10', load: '55')],
      [_WeekPrescription(2, '8-10')],
      [_WeekPrescription(2, '8-10')],
      [_WeekPrescription(2, '8-10')],
    ]),
    _ImportedExercise('cmbf', [
      [_WeekPrescription(2, '10', load: 'max')],
      [_WeekPrescription(2, '10', load: 'max')],
      [_WeekPrescription(2, '10', load: 'max')],
      [_WeekPrescription(2, '10')],
      [_WeekPrescription(2, '10')],
    ]),
    _ImportedExercise('combh', [
      [_WeekPrescription(2, '10', load: 'max')],
      [_WeekPrescription(2, '10', load: 'max')],
      [_WeekPrescription(2, '10', load: 'max', note: 'hiperhajlitas')],
      [_WeekPrescription(2, '10')],
      [_WeekPrescription(2, '10')],
    ]),
  ]),
];

const _exerciseIds = <String, String>{
  'Tempo 4-2-0': 'block1_tempo_420',
  'Low bar guggolás': 'low_bar_squat',
  'bench': 'comp_bench',
  'lehuzas magam melle': 'block1_lehuzas_magam_melle',
  'tarogatas': 'pec_deck',
  'b francia': 'ez_skull',
  'oldal emeles': 'lateral_raise',
  'deadlift': 'comp_deadlift',
  'szeles lehuzas': 'block1_szeles_lehuzas',
  'kalapacsb': 'hammer_curl',
  'oldalemeles': 'lateral_raise',
  'squat': 'comp_squat',
  'chest press alva': 'block1_chest_press_alva',
  'evezes szeles': 'block1_evezes_szeles',
  'hatsoval': 'rear_delt_fly',
  'cmbf': 'cmbf',
  'combh': 'combh',
};

const _customExercises = <Exercise>[
  Exercise(
    id: 'block1_tempo_420',
    name: 'Tempo 4-2-0',
    nameHu: 'Tempo 4-2-0',
    category: 'main',
    lift: Lift.squat,
    variation: true,
  ),
  Exercise(
    id: 'block1_lehuzas_magam_melle',
    name: 'lehuzas magam melle',
    nameHu: 'lehuzas magam melle',
    equipment: 'cable',
    isCustom: true,
  ),
  Exercise(
    id: 'block1_szeles_lehuzas',
    name: 'szeles lehuzas',
    nameHu: 'szeles lehuzas',
    equipment: 'cable',
    isCustom: true,
  ),
  Exercise(
    id: 'block1_chest_press_alva',
    name: 'chest press alva',
    nameHu: 'chest press alva',
    equipment: 'machine',
    isCustom: true,
  ),
  Exercise(
    id: 'block1_evezes_szeles',
    name: 'evezes szeles',
    nameHu: 'evezes szeles',
    equipment: 'machine',
    isCustom: true,
  ),
];

Future<Program> createBlock1Program(ExerciseRepository exerciseRepository) async {
  final knownExercises = await exerciseRepository.map();
  for (final exercise in _customExercises) {
    if (!knownExercises.containsKey(exercise.id)) {
      await exerciseRepository.save(exercise);
      knownExercises[exercise.id] = exercise;
    }
  }
  return buildBlock1Program({for (final entry in _exerciseIds.entries) entry.key: entry.value});
}

Program buildBlock1Program(Map<String, String> exerciseIds) {
  final exercises = <ProgramDay>[];
  for (final importedDay in _days) {
    final dayExercises = <ProgramExercise>[];
    for (final importedExercise in importedDay.exercises) {
      final exerciseId = exerciseIds[importedExercise.name];
      if (exerciseId == null) {
        throw StateError('No exercise mapping for "${importedExercise.name}".');
      }
      final sets = <PrescribedSet>[];
      for (var week = 0; week < importedExercise.weeks.length; week++) {
        for (var position = 0; position < importedExercise.weeks[week].length; position++) {
          sets.add(_prescribedSet(importedExercise.weeks[week][position], week, position));
        }
      }
      dayExercises.add(ProgramExercise(exerciseId: exerciseId, position: dayExercises.length, sets: sets));
    }
    exercises.add(
      ProgramDay(
        name: importedDay.name,
        weekday: importedDay.weekday,
        tag: importedDay.tag,
        position: exercises.length,
        exercises: dayExercises,
      ),
    );
  }
  return Program(
    name: block1ProgramName,
    description:
        'Imported from the Block1 worksheet of e2.0: five weeks, with Tuesday, Thursday, and Saturday sessions.',
    blocks: [
      ProgramBlock(
        name: 'Block 1',
        startDate: DateTime(2026, 10, 20),
        weekCount: 5,
        days: exercises,
      ),
    ],
  );
}

PrescribedSet _prescribedSet(_WeekPrescription source, int week, int position) {
  final (repsMin, repsMax) = _parseRepsPreservingOrder(source.reps);
  final load = source.load.trim();
  final range = _loadRange.firstMatch(load);
  final isMax = load.toLowerCase() == 'max';
  final noteParts = <String>[source.note.trim()];
  if (load.isNotEmpty && !isMax && range == null) {
    noteParts.add('Terhelés: $load');
  }
  return PrescribedSet(
    weekIndex: week,
    position: position,
    sets: source.sets,
    repsMin: repsMin,
    repsMax: repsMax,
    loadType: isMax
        ? LoadType.max
        : range != null
            ? LoadType.abs
            : LoadType.free,
    weight: range == null ? null : double.parse(range.group(1)!.replaceAll(',', '.')),
    weightMax: range?.group(2) == null ? null : double.parse(range!.group(2)!.replaceAll(',', '.')),
    note: noteParts.where((note) => note.isNotEmpty).join(' · '),
  );
}

final _loadRange = RegExp(r'^(\d+(?:[.,]\d+)?)(?:\s*-\s*(\d+(?:[.,]\d+)?))?$');

(int?, int?) _parseRepsPreservingOrder(String raw) {
  final match = RegExp(r'^(\d+)(?:\s*-\s*(\d+))?$').firstMatch(raw.trim());
  if (match == null) return (null, null);
  return (int.parse(match.group(1)!), int.parse(match.group(2) ?? match.group(1)!));
}
