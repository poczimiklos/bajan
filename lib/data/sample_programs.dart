import '../domain/load_parser.dart';
import 'models.dart';

/// Builds a PrescribedSet from coach notation.
PrescribedSet _ps({
  required int week,
  required int sets,
  String reps = '',
  String load = '',
  String note = '',
  String tempo = '',
  bool amrap = false,
  String? type,
  double? inc,
  int rest = 0,
}) {
  final (rMin, rMax) = parseReps(reps);
  final p = parsePrescription(load);
  String lt = LoadType.free;
  double? w = p.weight;
  if (type == LoadType.linear) {
    lt = LoadType.linear;
    w = inc;
  } else if (p.isMax) {
    lt = LoadType.max;
  } else if (p.isPercent) {
    lt = LoadType.pct;
  } else if (p.weight != null) {
    lt = LoadType.abs;
  } else if (p.rpeMin != null) {
    lt = LoadType.rpe;
  }
  return PrescribedSet(
    weekIndex: week,
    sets: sets,
    repsMin: rMin,
    repsMax: rMax,
    loadType: lt,
    weight: w,
    weightMax: p.weightMax,
    rpeMin: p.rpeMin,
    rpeMax: p.rpeMax,
    note: note,
    tempo: tempo,
    amrap: amrap,
    constant: p.isConstant,
    repeatUntil: p.isRepeat,
    restSec: rest,
  );
}

ProgramExercise _ex(String id, List<PrescribedSet> sets) {
  for (var i = 0; i < sets.length; i++) {
    sets[i].position = i;
  }
  return ProgramExercise(exerciseId: id, sets: sets);
}

// ───────────────────────── e2.0 · Block 1 (coach program) ─────────────────────────

/// One exercise row of the coach sheet: per week sets / reps / weight text.
ProgramExercise _coachRow(
  String exerciseId, {
  required String sets,
  required String reps,
  required List<String> weights, // one entry per week, '' = not prescribed yet
  List<String>? setsPerWeek,
  List<String>? repsPerWeek,
  List<String>? notes,
  String tempo = '',
}) {
  final out = <PrescribedSet>[];
  for (var w = 0; w < weights.length; w++) {
    final s = int.tryParse(setsPerWeek?[w] ?? sets) ?? 1;
    out.add(_ps(
      week: w,
      sets: s,
      reps: repsPerWeek?[w] ?? reps,
      load: weights[w],
      note: notes == null ? '' : notes[w],
      tempo: tempo,
    ));
  }
  return _ex(exerciseId, out);
}

Program coachBlockProgram() {
  const e = ''; // not prescribed yet (weeks 4-5)
  final day1 = ProgramDay(name: 'Day 1', weekday: DateTime.tuesday, exercises: [
    _coachRow('tempo_squat', sets: '1', reps: '2', weights: ['190', '195', '200', e, e], tempo: '4-2-0'),
    _coachRow('tempo_squat', sets: '1', reps: '2', weights: ['200', '205', '210', e, e], tempo: '4-2-0'),
    _coachRow('low_bar_squat', sets: '3', reps: '5', weights: ['185', '190', '192.5', e, e]),
    _coachRow('comp_bench', sets: '4', reps: '5', weights: ['105', '107.5', '110', e, e]),
    _coachRow('lat_pulldown',
        sets: '2',
        reps: '6',
        weights: ['65', '50', '65', e, e],
        repsPerWeek: ['6', '8', '7', '7', '7'],
        notes: ['pulldown to the side', 'outside machine', '', '', '']),
    _coachRow('pec_deck',
        sets: '2', reps: '8-10', weights: ['25', '120', '120', e, e], notes: ['incline pad', 'hoist', 'hoist', '', '']),
    _coachRow('ez_skull', sets: '2', reps: '8', weights: ['45', '45', '45', e, e]),
    _coachRow('lateral_raise',
        sets: '2', reps: '8-10', weights: ['18', '19', '19', e, e], repsPerWeek: ['8-10', '8', '8', '8', '8']),
  ]);
  final day2 = ProgramDay(name: 'Day 2', weekday: DateTime.thursday, exercises: [
    _coachRow('comp_bench', sets: '3', reps: '3', weights: ['120', '122.5', '125', e, e]),
    _coachRow('sumo_deadlift', sets: '1', reps: '2', weights: ['225', '230', '235', e, e]),
    _coachRow('sumo_deadlift', sets: '1', reps: '1', weights: ['235', '240', '245', e, e]),
    _coachRow('sumo_deadlift', sets: '3', reps: '4', weights: ['195', '197.5-200', '205', e, e]),
    _coachRow('lat_pulldown',
        sets: '2',
        reps: '6-12',
        weights: [e, e, '', e, e],
        repsPerWeek: ['6-12', '6-12', '7', '6-12', '6-12'],
        notes: ['wide, pull-up assist', 'wide, pull-up assist', 'bodyweight +5', '', '']),
    _coachRow('hammer_curl',
        sets: '2',
        reps: '6-12',
        weights: ['26', '26', '28', e, e],
        repsPerWeek: ['6-12', '6-12', '7-8', '6-12', '6-12'],
        notes: ['', '', 'weights 28-26', '', '']),
    _coachRow('lateral_raise', sets: '2', reps: '8', weights: ['19', '19', '19', e, e]),
  ]);
  final day3 = ProgramDay(name: 'Day 3', weekday: DateTime.saturday, exercises: [
    _coachRow('low_bar_squat',
        sets: '1', reps: '2', weights: ['195', '200', '205', e, e], setsPerWeek: ['1', '1', '1', '2', '2']),
    _coachRow('low_bar_squat',
        sets: '1', reps: '2', weights: ['205', '210', '215', e, e], setsPerWeek: ['1', '1', '1', '2', '2']),
    _coachRow('low_bar_squat', sets: '2', reps: '5', weights: ['185', '190', '195', e, e]),
    _coachRow('comp_bench', sets: '3', reps: '1', weights: ['125', '127.5', '130', e, e]),
    _coachRow('sumo_deadlift', sets: '1', reps: '5', weights: ['210', '220', '225', e, e]),
    _coachRow('sumo_deadlift', sets: '3', reps: '5', weights: ['192.5', '200', '200', e, e]),
    _coachRow('machine_chest_press',
        sets: '2',
        reps: '8-7',
        weights: ['18', '18', '18', e, e],
        repsPerWeek: ['7-8', '6-7', '5-8', '7-8', '7-8'],
        notes: ['reps 8-7 · weight 18-17', 'reps 7-6 · weight 18-17', 'reps 8-5 · weight 18-17', '', '']),
    _coachRow('chest_supported_row',
        sets: '2',
        reps: '6',
        weights: ['65', '65', '65', e, e],
        repsPerWeek: ['6', '6', '8', '6', '6'],
        notes: ['wide grip', '', '', '', '']),
    _coachRow('rear_delt_fly', sets: '2', reps: '8-10', weights: ['55', '55', e, e, e]),
    _coachRow('cmbf', sets: '2', reps: '10', weights: ['max', 'max', 'max', e, e]),
    _coachRow('combh',
        sets: '2', reps: '10', weights: ['max', 'max', 'max', e, e], notes: ['', '', 'hyperextension', '', '']),
  ]);
  return Program(
    name: 'e2.0 · Coach program',
    description:
        'Tue/Thu/Sat block imported from the coach sheet (e2.0 / Block-1). Weeks 4-5 weights are still to be prescribed.',
    blocks: [
      ProgramBlock(name: 'Block 1', startDate: DateTime(2026, 10, 20), weekCount: 5, days: [day1, day2, day3]),
    ],
  );
}

// ───────────────────────── Classic samples ─────────────────────────

Program startingStrength() {
  // 2-week rotation: week 1 = A B A, week 2 = B A B (Mon/Wed/Fri). Linear +kg/session.
  ProgramExercise lin(String id, String reps, int sets, double inc, List<int> weeks) =>
      _ex(id, [for (final w in weeks) _ps(week: w, sets: sets, reps: reps, type: LoadType.linear, inc: inc)]);
  final mon = ProgramDay(name: 'Workout A / B', weekday: DateTime.monday, exercises: [
    lin('comp_squat', '5', 3, 5, [0, 1]),
    lin('comp_bench', '5', 3, 2.5, [0]),
    lin('ohp', '5', 3, 2.5, [1]),
    lin('conv_deadlift', '5', 1, 5, [0]),
    lin('power_clean', '3', 5, 2.5, [1]),
  ]);
  final wed = ProgramDay(name: 'Workout B / A', weekday: DateTime.wednesday, exercises: [
    lin('comp_squat', '5', 3, 5, [0, 1]),
    lin('ohp', '5', 3, 2.5, [0]),
    lin('comp_bench', '5', 3, 2.5, [1]),
    lin('power_clean', '3', 5, 2.5, [0]),
    lin('conv_deadlift', '5', 1, 5, [1]),
  ]);
  final fri = ProgramDay(name: 'Workout A / B', weekday: DateTime.friday, exercises: [
    lin('comp_squat', '5', 3, 5, [0, 1]),
    lin('comp_bench', '5', 3, 2.5, [0]),
    lin('ohp', '5', 3, 2.5, [1]),
    lin('conv_deadlift', '5', 1, 5, [0]),
    lin('power_clean', '3', 5, 2.5, [1]),
  ]);
  return Program(
    name: 'Starting Strength',
    description: 'Novice linear progression. A: squat, bench, deadlift. B: squat, press, power clean. '
        'Loads are last session + increment; enter your first weights manually.',
    isSample: true,
    blocks: [
      ProgramBlock(name: 'Rotation', weekCount: 2, days: [mon, wed, fri])
    ],
  );
}

Program wendler531() {
  // Percentages are of the Training Max (set it in Profile). Wave: 5s / 3s / 5-3-1 / deload.
  List<PrescribedSet> wave(int w, {bool bbb = false}) {
    const pct = [
      [65, 75, 85],
      [70, 80, 90],
      [75, 85, 95],
      [40, 50, 60],
    ];
    const reps = [
      [5, 5, 5],
      [3, 3, 3],
      [5, 3, 1],
      [5, 5, 5],
    ];
    final out = <PrescribedSet>[];
    for (var i = 0; i < 3; i++) {
      out.add(_ps(week: w, sets: 1, reps: '${reps[w][i]}', load: '${pct[w][i]}%', amrap: w < 3 && i == 2));
    }
    return out;
  }

  ProgramExercise main(String id) => _ex(id, [for (var w = 0; w < 4; w++) ...wave(w)]);
  ProgramExercise bbb(String id) =>
      _ex(id, [for (var w = 0; w < 4; w++) _ps(week: w, sets: 5, reps: '10', load: '50%')]);

  return Program(
    name: '5/3/1',
    description:
        'Wendler 5/3/1 with Boring But Big supplemental work. Percentages are of your Training Max (≈90% of 1RM).',
    isSample: true,
    blocks: [
      ProgramBlock(name: '4-week wave', weekCount: 4, days: [
        ProgramDay(name: 'Overhead Press', weekday: DateTime.monday, exercises: [main('ohp'), bbb('ohp')]),
        ProgramDay(
            name: 'Deadlift', weekday: DateTime.tuesday, exercises: [main('conv_deadlift'), bbb('conv_deadlift')]),
        ProgramDay(name: 'Bench Press', weekday: DateTime.thursday, exercises: [main('comp_bench'), bbb('comp_bench')]),
        ProgramDay(name: 'Squat', weekday: DateTime.friday, exercises: [main('comp_squat'), bbb('comp_squat')]),
      ]),
    ],
  );
}

Program texasMethod() {
  // Percentages of Training Max, where TM = current 5RM.
  ProgramExercise rep(String id, int sets, String pct, int weeks) =>
      _ex(id, [for (var w = 0; w < weeks; w++) _ps(week: w, sets: sets, reps: '5', load: pct)]);
  const weeks = 4;
  return Program(
    name: 'Texas Method',
    description: 'Volume / Recovery / Intensity week. Set your Training Max to your current 5RM; '
        'raise it each time Friday\'s 5-rep PR succeeds.',
    isSample: true,
    blocks: [
      ProgramBlock(name: 'Weekly cycle', weekCount: weeks, days: [
        ProgramDay(name: 'Volume', weekday: DateTime.monday, exercises: [
          rep('comp_squat', 5, '90%', weeks),
          rep('comp_bench', 5, '90%', weeks),
          _ex('barbell_row', [for (var w = 0; w < weeks; w++) _ps(week: w, sets: 3, reps: '8', load: 'R8')]),
        ]),
        ProgramDay(name: 'Recovery', weekday: DateTime.wednesday, exercises: [
          rep('comp_squat', 2, '80%', weeks),
          rep('ohp', 3, '90%', weeks),
          _ex('pullups', [for (var w = 0; w < weeks; w++) _ps(week: w, sets: 3, reps: '8', load: 'max')]),
        ]),
        ProgramDay(name: 'Intensity', weekday: DateTime.friday, exercises: [
          rep('comp_squat', 1, '100%', weeks),
          rep('comp_bench', 1, '100%', weeks),
          rep('conv_deadlift', 1, '100%', weeks),
        ]),
      ]),
    ],
  );
}

Program emptyCustom(String name) => Program(
      name: name,
      description: 'Custom powerlifting program',
      blocks: [ProgramBlock(name: 'Block 1', weekCount: 4, days: [])],
    );
