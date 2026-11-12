import 'package:uuid/uuid.dart';

const _uuid = Uuid();
String newId() => _uuid.v4();
int nowMs() => DateTime.now().millisecondsSinceEpoch;
DateTime fromMs(int ms) => DateTime.fromMillisecondsSinceEpoch(ms);

typedef DbRow = Map<String, Object?>;

class SetType {
  static const warmup = 'warmup';
  static const working = 'working';
  static const backoff = 'backoff';
  static const amrap = 'amrap';
  static const custom = 'custom';
  static const all = [working, warmup, backoff, amrap, custom];

  static String short(String t) => switch (t) {
        'warmup' => 'W',
        'backoff' => 'B',
        'amrap' => 'A',
        'custom' => 'C',
        _ => '',
      };
  static String label(String t) => switch (t) {
        'warmup' => 'Warm-up',
        'backoff' => 'Back-off',
        'amrap' => 'AMRAP',
        'custom' => 'Custom',
        _ => 'Working',
      };
}

/// Lift family used for SBD statistics.
class Lift {
  static const squat = 'squat';
  static const bench = 'bench';
  static const deadlift = 'deadlift';
  static const all = [squat, bench, deadlift];
  static String label(String l) => switch (l) { 'squat' => 'Squat', 'bench' => 'Bench', _ => 'Deadlift' };
  static String short(String l) => switch (l) { 'squat' => 'SQ', 'bench' => 'BP', _ => 'DL' };
}

class Exercise {
  final String id;
  final String name;
  final String nameHu;
  final String category; // main | accessory
  final String? lift; // squat | bench | deadlift
  final String equipment;
  final bool variation; // true = not the competition-style lift
  final bool isCustom;
  final bool archived;

  const Exercise({
    required this.id,
    required this.name,
    this.nameHu = '',
    this.category = 'accessory',
    this.lift,
    this.equipment = 'barbell',
    this.variation = false,
    this.isCustom = false,
    this.archived = false,
  });

  DbRow toMap() => {
        'id': id,
        'name': name,
        'name_hu': nameHu,
        'category': category,
        'lift': lift,
        'equipment': equipment,
        'variation': variation ? 1 : 0,
        'is_custom': isCustom ? 1 : 0,
        'archived': archived ? 1 : 0,
        'updated_at': nowMs(),
      };

  factory Exercise.fromMap(DbRow m) => Exercise(
        id: m['id'] as String,
        name: m['name'] as String,
        nameHu: (m['name_hu'] as String?) ?? '',
        category: (m['category'] as String?) ?? 'accessory',
        lift: m['lift'] as String?,
        equipment: (m['equipment'] as String?) ?? 'barbell',
        variation: (m['variation'] as int? ?? 0) == 1,
        isCustom: (m['is_custom'] as int? ?? 0) == 1,
        archived: (m['archived'] as int? ?? 0) == 1,
      );
}

class SetEntry {
  String id;
  String type;
  String prescText;
  int? prescReps;
  double? prescWeight; // kg
  double? targetRpe;
  int? reps;
  double? weight; // kg
  double? rpe;
  bool completed;
  String note;

  SetEntry({
    String? id,
    this.type = SetType.working,
    this.prescText = '',
    this.prescReps,
    this.prescWeight,
    this.targetRpe,
    this.reps,
    this.weight,
    this.rpe,
    this.completed = false,
    this.note = '',
  }) : id = id ?? newId();

  DbRow toMap(String workoutExerciseId, int position) => {
        'id': id,
        'workout_exercise_id': workoutExerciseId,
        'position': position,
        'set_type': type,
        'presc_text': prescText,
        'presc_reps': prescReps,
        'presc_weight': prescWeight,
        'target_rpe': targetRpe,
        'reps': reps,
        'weight': weight,
        'rpe': rpe,
        'completed': completed ? 1 : 0,
        'note': note,
      };

  factory SetEntry.fromMap(DbRow m) => SetEntry(
        id: m['id'] as String,
        type: m['set_type'] as String,
        prescText: (m['presc_text'] as String?) ?? '',
        prescReps: m['presc_reps'] as int?,
        prescWeight: (m['presc_weight'] as num?)?.toDouble(),
        targetRpe: (m['target_rpe'] as num?)?.toDouble(),
        reps: m['reps'] as int?,
        weight: (m['weight'] as num?)?.toDouble(),
        rpe: (m['rpe'] as num?)?.toDouble(),
        completed: (m['completed'] as int? ?? 0) == 1,
        note: (m['note'] as String?) ?? '',
      );
}

class WorkoutExercise {
  String id;
  Exercise exercise;
  List<SetEntry> sets;
  String notes;
  String tempo;

  WorkoutExercise({String? id, required this.exercise, List<SetEntry>? sets, this.notes = '', this.tempo = ''})
      : id = id ?? newId(),
        sets = sets ?? [];
}

class Workout {
  String id;
  String name;
  DateTime date;
  DateTime startedAt;
  DateTime? endedAt;
  String tag;
  String notes;
  int? stress;
  int? fatigueSq;
  int? fatigueBp;
  int? fatigueDl;
  String status; // active | done
  String? programBlockId;
  List<WorkoutExercise> exercises;

  Workout({
    String? id,
    this.name = 'Workout',
    DateTime? date,
    DateTime? startedAt,
    this.endedAt,
    this.tag = '',
    this.notes = '',
    this.stress,
    this.fatigueSq,
    this.fatigueBp,
    this.fatigueDl,
    this.status = 'active',
    this.programBlockId,
    List<WorkoutExercise>? exercises,
  })  : id = id ?? newId(),
        date = date ?? DateTime.now(),
        startedAt = startedAt ?? DateTime.now(),
        exercises = exercises ?? [];

  /// New instance sharing the same children. Used to notify Riverpod
  /// after in-place mutation.
  Workout copyRef() => Workout(
        id: id,
        name: name,
        date: date,
        startedAt: startedAt,
        endedAt: endedAt,
        tag: tag,
        notes: notes,
        stress: stress,
        fatigueSq: fatigueSq,
        fatigueBp: fatigueBp,
        fatigueDl: fatigueDl,
        status: status,
        programBlockId: programBlockId,
        exercises: exercises,
      );

  Iterable<SetEntry> get completedSets => exercises.expand((e) => e.sets).where((s) => s.completed);

  double get volume => exercises
      .expand((e) => e.sets)
      .where((s) => s.completed && s.type != SetType.warmup)
      .fold(0.0, (a, s) => a + (s.weight ?? 0) * (s.reps ?? 0));

  DbRow toMap() => {
        'id': id,
        'name': name,
        'date': date.millisecondsSinceEpoch,
        'started_at': startedAt.millisecondsSinceEpoch,
        'ended_at': endedAt?.millisecondsSinceEpoch,
        'tag': tag,
        'notes': notes,
        'stress': stress,
        'fatigue_sq': fatigueSq,
        'fatigue_bp': fatigueBp,
        'fatigue_dl': fatigueDl,
        'status': status,
        'block_id': programBlockId,
        'updated_at': nowMs(),
      };

  factory Workout.fromMap(DbRow m) => Workout(
        id: m['id'] as String,
        name: (m['name'] as String?) ?? 'Workout',
        date: fromMs(m['date'] as int),
        startedAt: fromMs(m['started_at'] as int),
        endedAt: m['ended_at'] == null ? null : fromMs(m['ended_at'] as int),
        tag: (m['tag'] as String?) ?? '',
        notes: (m['notes'] as String?) ?? '',
        stress: m['stress'] as int?,
        fatigueSq: m['fatigue_sq'] as int?,
        fatigueBp: m['fatigue_bp'] as int?,
        fatigueDl: m['fatigue_dl'] as int?,
        status: (m['status'] as String?) ?? 'done',
        programBlockId: m['block_id'] as String?,
      );
}

// ───────────────────────────── Programs ─────────────────────────────

class LoadType {
  static const abs = 'abs'; // absolute kg
  static const pct = 'pct'; // % of training max
  static const rpe = 'rpe'; // athlete picks load for RPE target
  static const max = 'max'; // best effort / free choice
  static const free = 'free'; // not prescribed (yet)
  static const linear = 'linear'; // last weight + increment (kg)
}

class PrescribedSet {
  String id;
  int weekIndex; // 0-based
  int position;
  int sets;
  int? repsMin;
  int? repsMax;
  String loadType;
  double? weight; // kg, %, or increment depending on loadType
  double? weightMax;
  double? rpeMin;
  double? rpeMax;
  int restSec;
  String tempo;
  String note;
  bool amrap;
  bool constant;
  bool repeatUntil;

  PrescribedSet({
    String? id,
    this.weekIndex = 0,
    this.position = 0,
    this.sets = 1,
    this.repsMin,
    this.repsMax,
    this.loadType = LoadType.free,
    this.weight,
    this.weightMax,
    this.rpeMin,
    this.rpeMax,
    this.restSec = 0,
    this.tempo = '',
    this.note = '',
    this.amrap = false,
    this.constant = false,
    this.repeatUntil = false,
  }) : id = id ?? newId();

  PrescribedSet copyForWeek(int week) => PrescribedSet(
        weekIndex: week,
        position: position,
        sets: sets,
        repsMin: repsMin,
        repsMax: repsMax,
        loadType: loadType,
        weight: weight,
        weightMax: weightMax,
        rpeMin: rpeMin,
        rpeMax: rpeMax,
        restSec: restSec,
        tempo: tempo,
        note: note,
        amrap: amrap,
        constant: constant,
        repeatUntil: repeatUntil,
      );

  String get repsText {
    if (repsMin == null) return '';
    if (repsMax == null || repsMax == repsMin) return '$repsMin';
    return '$repsMin-$repsMax';
  }

  String _n(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  String get loadText {
    final r = rpeMin == null
        ? ''
        : (rpeMax == null || rpeMax == rpeMin ? 'R${_n(rpeMin!)}' : 'R${_n(rpeMin!)}-${_n(rpeMax!)}');
    switch (loadType) {
      case LoadType.abs:
        final w = weight == null ? '' : (weightMax != null ? '[${_n(weight!)}-${_n(weightMax!)}]' : _n(weight!));
        return [w, r].where((e) => e.isNotEmpty).join(' ');
      case LoadType.pct:
        return weight == null ? '' : '${_n(weight!)}%';
      case LoadType.linear:
        return weight == null ? 'last +?' : 'last +${_n(weight!)}';
      case LoadType.rpe:
        return r;
      case LoadType.max:
        return 'max';
      default:
        return '';
    }
  }

  /// e.g. "3×5 @ 190" or "2×8-10 @ R8-9".
  String describe() {
    final parts = <String>['$sets×${repsText.isEmpty ? '?' : repsText}'];
    final l = loadText;
    if (l.isNotEmpty) parts.add('@ $l');
    if (amrap) parts.add('AMRAP');
    return parts.join(' ');
  }

  DbRow toMap(String programExerciseId) => {
        'id': id,
        'program_exercise_id': programExerciseId,
        'week_index': weekIndex,
        'position': position,
        'sets': sets,
        'reps_min': repsMin,
        'reps_max': repsMax,
        'load_type': loadType,
        'weight': weight,
        'weight_max': weightMax,
        'rpe_min': rpeMin,
        'rpe_max': rpeMax,
        'rest_sec': restSec,
        'tempo': tempo,
        'note': note,
        'amrap': amrap ? 1 : 0,
        'constant_load': constant ? 1 : 0,
        'repeat_until': repeatUntil ? 1 : 0,
      };

  factory PrescribedSet.fromMap(DbRow m) => PrescribedSet(
        id: m['id'] as String,
        weekIndex: m['week_index'] as int,
        position: m['position'] as int,
        sets: m['sets'] as int,
        repsMin: m['reps_min'] as int?,
        repsMax: m['reps_max'] as int?,
        loadType: m['load_type'] as String,
        weight: (m['weight'] as num?)?.toDouble(),
        weightMax: (m['weight_max'] as num?)?.toDouble(),
        rpeMin: (m['rpe_min'] as num?)?.toDouble(),
        rpeMax: (m['rpe_max'] as num?)?.toDouble(),
        restSec: (m['rest_sec'] as int?) ?? 0,
        tempo: (m['tempo'] as String?) ?? '',
        note: (m['note'] as String?) ?? '',
        amrap: (m['amrap'] as int? ?? 0) == 1,
        constant: (m['constant_load'] as int? ?? 0) == 1,
        repeatUntil: (m['repeat_until'] as int? ?? 0) == 1,
      );
}

class ProgramExercise {
  String id;
  String exerciseId;
  int position;
  List<PrescribedSet> sets;
  ProgramExercise({String? id, required this.exerciseId, this.position = 0, List<PrescribedSet>? sets})
      : id = id ?? newId(),
        sets = sets ?? [];

  List<PrescribedSet> forWeek(int week) =>
      (sets.where((s) => s.weekIndex == week).toList()..sort((a, b) => a.position.compareTo(b.position)));
}

class ProgramDay {
  String id;
  String name;
  int weekday; // DateTime.monday..sunday
  String tag; // e.g. "SQ1 BP2"
  int position;
  List<ProgramExercise> exercises;
  ProgramDay(
      {String? id,
      required this.name,
      required this.weekday,
      this.tag = '',
      this.position = 0,
      List<ProgramExercise>? exercises})
      : id = id ?? newId(),
        exercises = exercises ?? [];

  bool hasWork(int week) => exercises.any((e) => e.forWeek(week).isNotEmpty);
}

class ProgramBlock {
  String id;
  String name;
  DateTime? startDate;
  int weekCount;
  int position;
  List<ProgramDay> days;
  ProgramBlock(
      {String? id, required this.name, this.startDate, this.weekCount = 5, this.position = 0, List<ProgramDay>? days})
      : id = id ?? newId(),
        days = days ?? [];
}

class Program {
  String id;
  String name;
  String description;
  bool isSample;
  List<ProgramBlock> blocks;
  Program({String? id, required this.name, this.description = '', this.isSample = false, List<ProgramBlock>? blocks})
      : id = id ?? newId(),
        blocks = blocks ?? [];
}

// ───────────────────────────── Records & misc ─────────────────────────────

class PersonalRecord {
  final String id;
  final String exerciseId;
  final String exerciseName;
  final String kind; // weight | e1rm | reps
  final double value;
  final double? previous;
  final int? reps;
  final double? weight;
  final DateTime date;
  final String workoutId;

  const PersonalRecord({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.kind,
    required this.value,
    this.previous,
    this.reps,
    this.weight,
    required this.date,
    required this.workoutId,
  });

  double? get improvement => previous == null ? null : value - previous!;

  String get kindLabel => switch (kind) {
        'weight' => 'Heaviest weight',
        'e1rm' => 'Best e1RM',
        _ => 'Rep record',
      };

  DbRow toMap() => {
        'id': id,
        'exercise_id': exerciseId,
        'exercise_name': exerciseName,
        'kind': kind,
        'value': value,
        'previous': previous,
        'reps': reps,
        'weight': weight,
        'date': date.millisecondsSinceEpoch,
        'workout_id': workoutId,
      };

  factory PersonalRecord.fromMap(DbRow m) => PersonalRecord(
        id: m['id'] as String,
        exerciseId: m['exercise_id'] as String,
        exerciseName: (m['exercise_name'] as String?) ?? '',
        kind: m['kind'] as String,
        value: (m['value'] as num).toDouble(),
        previous: (m['previous'] as num?)?.toDouble(),
        reps: m['reps'] as int?,
        weight: (m['weight'] as num?)?.toDouble(),
        date: fromMs(m['date'] as int),
        workoutId: m['workout_id'] as String,
      );
}

class BodyweightEntry {
  final String id;
  final DateTime date;
  final double kg;
  BodyweightEntry({String? id, required this.date, required this.kg}) : id = id ?? newId();
  DbRow toMap() => {'id': id, 'date': date.millisecondsSinceEpoch, 'kg': kg, 'updated_at': nowMs()};
  factory BodyweightEntry.fromMap(DbRow m) =>
      BodyweightEntry(id: m['id'] as String, date: fromMs(m['date'] as int), kg: (m['kg'] as num).toDouble());
}

/// One completed set joined with its workout date and exercise info.
class SetRecord {
  final DateTime date;
  final String workoutId;
  final String exerciseId;
  final String exerciseName;
  final String? lift;
  final bool variation;
  final String setType;
  final double weight;
  final int reps;
  final double? rpe;
  const SetRecord({
    required this.date,
    required this.workoutId,
    required this.exerciseId,
    required this.exerciseName,
    required this.lift,
    required this.variation,
    required this.setType,
    required this.weight,
    required this.reps,
    required this.rpe,
  });
}

/// Explains coach day tags such as "SQ1 BP2 DL2".
String describeTag(String tag) {
  final parts = tag.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty);
  final names = {'SQ': 'squat', 'BP': 'bench', 'DL': 'deadlift'};
  final out = <String>[];
  for (final p in parts) {
    final m = RegExp(r'^(SQ|BP|DL)(\d)$', caseSensitive: false).firstMatch(p);
    if (m == null) continue;
    final lvl = int.parse(m.group(2)!);
    final word = lvl == 1
        ? 'primary'
        : lvl == 2
            ? 'secondary'
            : 'level $lvl';
    out.add('${p.toUpperCase()} = $word ${names[m.group(1)!.toUpperCase()]}');
  }
  return out.join(' · ');
}
