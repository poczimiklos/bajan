import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// All tables included in export/backup, in dependency order.
const kTables = [
  'exercises',
  'workouts',
  'workout_exercises',
  'workout_sets',
  'programs',
  'program_blocks',
  'program_days',
  'program_exercises',
  'program_sets',
  'personal_records',
  'bodyweight',
];

const _schemaV1 = <String>[
  '''CREATE TABLE exercises(
    id TEXT PRIMARY KEY, name TEXT NOT NULL, name_hu TEXT, category TEXT NOT NULL,
    lift TEXT, equipment TEXT, variation INTEGER NOT NULL DEFAULT 0,
    is_custom INTEGER NOT NULL DEFAULT 0, archived INTEGER NOT NULL DEFAULT 0,
    updated_at INTEGER NOT NULL, deleted_at INTEGER)''',
  '''CREATE TABLE workouts(
    id TEXT PRIMARY KEY, name TEXT, date INTEGER NOT NULL, started_at INTEGER NOT NULL,
    ended_at INTEGER, tag TEXT, notes TEXT, stress INTEGER, fatigue_sq INTEGER,
    fatigue_bp INTEGER, fatigue_dl INTEGER, status TEXT NOT NULL, block_id TEXT,
    updated_at INTEGER NOT NULL, deleted_at INTEGER)''',
  '''CREATE TABLE workout_exercises(
    id TEXT PRIMARY KEY, workout_id TEXT NOT NULL, exercise_id TEXT NOT NULL,
    position INTEGER NOT NULL, notes TEXT, tempo TEXT)''',
  '''CREATE TABLE workout_sets(
    id TEXT PRIMARY KEY, workout_exercise_id TEXT NOT NULL, position INTEGER NOT NULL,
    set_type TEXT NOT NULL, presc_text TEXT, presc_reps INTEGER, presc_weight REAL,
    target_rpe REAL, reps INTEGER, weight REAL, rpe REAL,
    completed INTEGER NOT NULL DEFAULT 0, note TEXT)''',
  '''CREATE TABLE programs(
    id TEXT PRIMARY KEY, name TEXT NOT NULL, description TEXT,
    is_sample INTEGER NOT NULL DEFAULT 0, updated_at INTEGER NOT NULL, deleted_at INTEGER)''',
  '''CREATE TABLE program_blocks(
    id TEXT PRIMARY KEY, program_id TEXT NOT NULL, name TEXT NOT NULL,
    start_date INTEGER, week_count INTEGER NOT NULL, position INTEGER NOT NULL)''',
  '''CREATE TABLE program_days(
    id TEXT PRIMARY KEY, block_id TEXT NOT NULL, name TEXT NOT NULL,
    weekday INTEGER NOT NULL, tag TEXT, position INTEGER NOT NULL)''',
  '''CREATE TABLE program_exercises(
    id TEXT PRIMARY KEY, day_id TEXT NOT NULL, exercise_id TEXT NOT NULL,
    position INTEGER NOT NULL)''',
  '''CREATE TABLE program_sets(
    id TEXT PRIMARY KEY, program_exercise_id TEXT NOT NULL, week_index INTEGER NOT NULL,
    position INTEGER NOT NULL, sets INTEGER NOT NULL, reps_min INTEGER, reps_max INTEGER,
    load_type TEXT NOT NULL, weight REAL, weight_max REAL, rpe_min REAL, rpe_max REAL,
    rest_sec INTEGER, tempo TEXT, note TEXT, amrap INTEGER NOT NULL DEFAULT 0,
    constant_load INTEGER NOT NULL DEFAULT 0, repeat_until INTEGER NOT NULL DEFAULT 0)''',
  '''CREATE TABLE personal_records(
    id TEXT PRIMARY KEY, exercise_id TEXT NOT NULL, exercise_name TEXT, kind TEXT NOT NULL,
    value REAL NOT NULL, previous REAL, reps INTEGER, weight REAL,
    date INTEGER NOT NULL, workout_id TEXT NOT NULL)''',
  '''CREATE TABLE bodyweight(
    id TEXT PRIMARY KEY, date INTEGER NOT NULL, kg REAL NOT NULL, updated_at INTEGER NOT NULL)''',
  // Local change queue consumed by the (separate) cloud sync layer.
  '''CREATE TABLE sync_outbox(
    id INTEGER PRIMARY KEY AUTOINCREMENT, entity TEXT NOT NULL, entity_id TEXT NOT NULL,
    op TEXT NOT NULL, ts INTEGER NOT NULL)''',
  'CREATE INDEX idx_we_workout ON workout_exercises(workout_id)',
  'CREATE INDEX idx_we_exercise ON workout_exercises(exercise_id)',
  'CREATE INDEX idx_ws_we ON workout_sets(workout_exercise_id)',
  'CREATE INDEX idx_workouts_date ON workouts(date)',
  'CREATE INDEX idx_pr_ex ON personal_records(exercise_id, kind)',
];

class AppDatabase {
  Database? _db;

  Future<Database> get db async => _db ??= await _open();

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    return openDatabase(
      p.join(dir, 'powerlifting.db'),
      version: 1,
      onCreate: (d, v) async {
        for (final s in _schemaV1) {
          await d.execute(s);
        }
      },
      onUpgrade: (d, from, to) async {
        // Add migration steps here, e.g.
        // if (from < 2) { await d.execute('ALTER TABLE ...'); }
      },
    );
  }
}

/// Records a local change for the sync layer.
Future<void> enqueue(DatabaseExecutor ex, String entity, String id, [String op = 'upsert']) {
  return ex.insert('sync_outbox', {
    'entity': entity,
    'entity_id': id,
    'op': op,
    'ts': DateTime.now().millisecondsSinceEpoch,
  });
}

String sqlIn(Iterable<Object?> ids) => ids.map((_) => '?').join(',');
