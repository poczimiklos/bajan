import 'models.dart';

const _sq = Lift.squat, _bp = Lift.bench, _dl = Lift.deadlift;

/// Built-in exercise library (stable ids so programs can reference them).
const List<Exercise> seedExercises = [
  // ── Main lifts ──
  Exercise(id: 'comp_squat', name: 'Competition Squat', nameHu: 'Versenyguggolás', category: 'main', lift: _sq),
  Exercise(
      id: 'high_bar_squat',
      name: 'High Bar Squat',
      nameHu: 'High bar guggolás',
      category: 'main',
      lift: _sq,
      variation: true),
  Exercise(id: 'low_bar_squat', name: 'Low Bar Squat', nameHu: 'Low bar guggolás', category: 'main', lift: _sq),
  Exercise(
      id: 'tempo_squat',
      name: 'Tempo Low Bar Squat',
      nameHu: 'Tempó guggolás',
      category: 'main',
      lift: _sq,
      variation: true),
  Exercise(
      id: 'tempo_bench',
      name: 'Tempo Bench Press',
      nameHu: 'Tempó fekvenyomás',
      category: 'main',
      lift: _bp,
      variation: true),
  Exercise(id: 'comp_bench', name: 'Competition Bench Press', nameHu: 'Fekvenyomás', category: 'main', lift: _bp),
  Exercise(
      id: 'close_grip_bench',
      name: 'Close Grip Bench Press',
      nameHu: 'Szűk fekvenyomás',
      category: 'main',
      lift: _bp,
      variation: true),
  Exercise(
      id: 'paused_bench',
      name: 'Paused Bench Press',
      nameHu: 'Megállásos fekvenyomás',
      category: 'main',
      lift: _bp,
      variation: true),
  Exercise(
      id: 'larsen_press',
      name: 'Larsen Press',
      nameHu: 'Larsen fekvenyomás',
      category: 'main',
      lift: _bp,
      variation: true),
  Exercise(id: 'comp_deadlift', name: 'Competition Deadlift', nameHu: 'Versenyfelhúzás', category: 'main', lift: _dl),
  Exercise(id: 'sumo_deadlift', name: 'Sumo Deadlift', nameHu: 'Szumó felhúzás', category: 'main', lift: _dl),
  Exercise(
      id: 'conv_deadlift', name: 'Conventional Deadlift', nameHu: 'Hagyományos felhúzás', category: 'main', lift: _dl),
  Exercise(id: 'ohp', name: 'Overhead Press', nameHu: 'Vállnyomás', category: 'main'),
  Exercise(id: 'power_clean', name: 'Power Clean', nameHu: 'Power clean', category: 'main'),
  // ── Accessories ──
  Exercise(id: 'rdl', name: 'Romanian Deadlift', nameHu: 'Román felhúzás', lift: _dl),
  Exercise(id: 'barbell_row', name: 'Barbell Row', nameHu: 'Evezés rúddal'),
  Exercise(id: 'lat_pulldown', name: 'Lat Pulldown', nameHu: 'Lehúzás', equipment: 'cable'),
  Exercise(id: 'pullups', name: 'Pull-ups', nameHu: 'Húzódzkodás', equipment: 'bodyweight'),
  Exercise(id: 'tri_pushdown', name: 'Triceps Pushdown', nameHu: 'Tricepsz letolás', equipment: 'cable'),
  Exercise(id: 'leg_press', name: 'Leg Press', nameHu: 'Lábtoló', lift: _sq, equipment: 'machine'),
  Exercise(
      id: 'bulgarian_split',
      name: 'Bulgarian Split Squat',
      nameHu: 'Bolgár guggolás',
      lift: _sq,
      equipment: 'dumbbell'),
  Exercise(id: 'ham_curl', name: 'Hamstring Curl', nameHu: 'Combhajlítás', equipment: 'machine'),
  Exercise(id: 'leg_extension', name: 'Leg Extension', nameHu: 'Combfeszítő', equipment: 'machine'),
  Exercise(id: 'face_pull', name: 'Face Pull', nameHu: 'Face pull', equipment: 'cable'),
  Exercise(id: 'hack_squat', name: 'Hack Squat', nameHu: 'Hack guggolás', lift: _sq, equipment: 'machine'),
  Exercise(id: 'machine_chest_press', name: 'Seated Chest Press', nameHu: 'Ülő mellnyomás', equipment: 'machine'),
  Exercise(
      id: 'one_arm_db_bench',
      name: 'One-Arm Dumbbell Bench Press',
      nameHu: 'Egykezes fekvenyomás',
      equipment: 'dumbbell'),
  Exercise(id: 'pec_deck', name: 'Pec Deck / Fly', nameHu: 'Tárogatás', equipment: 'machine'),
  Exercise(
      id: 'chest_supported_row',
      name: 'Chest-Supported Row',
      nameHu: 'Mellkastámasztásos evezés',
      equipment: 'machine'),
  Exercise(id: 'ez_skull', name: 'EZ-Bar Skull Crusher', nameHu: 'Francia nyomás', equipment: 'barbell'),
  Exercise(
      id: 'oh_tri_ext', name: 'Overhead Triceps Extension', nameHu: 'Tricepsz nyújtás fej fölött', equipment: 'cable'),
  Exercise(id: 'hammer_curl', name: 'Hammer Curl', nameHu: 'Kalapács bicepsz', equipment: 'dumbbell'),
  Exercise(id: 'incline_curl', name: 'Incline Dumbbell Curl', nameHu: 'Döntött pados bicepsz', equipment: 'dumbbell'),
  Exercise(id: 'reverse_curl', name: 'Reverse Curl', nameHu: 'Fordított bicepsz', equipment: 'dumbbell'),
  Exercise(id: 'lateral_raise', name: 'Lateral Raise', nameHu: 'Oldalemelés', equipment: 'dumbbell'),
  Exercise(id: 'rear_delt_fly', name: 'Rear Delt Fly', nameHu: 'Hátsó váll', equipment: 'machine'),
  Exercise(id: 'hyperextension', name: 'Hyperextension', nameHu: 'Hiperextenzió', equipment: 'bodyweight'),
  Exercise(id: 'cmbf', name: 'CMBF (coach abbreviation)', nameHu: 'cmbf', equipment: 'machine', isCustom: true),
  Exercise(id: 'combh', name: 'COMBH (coach abbreviation)', nameHu: 'combh', equipment: 'machine', isCustom: true),
];
