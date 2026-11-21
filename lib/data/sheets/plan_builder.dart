import '../../domain/load_parser.dart';
import '../models.dart';
import 'sheet_plan.dart';

const _hu = {
  'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ö': 'o', 'ő': 'o', 'ú': 'u', 'ü': 'u', 'ű': 'u', //
};

/// Kisbetű, ékezet és írásjelek nélküli kulcs a névillesztéshez.
String normName(String s) {
  final b = StringBuffer();
  for (final ch in s.toLowerCase().split('')) {
    final c = _hu[ch] ?? ch;
    if (RegExp(r'[a-z0-9]').hasMatch(c)) b.write(c);
  }
  return b.toString();
}

/// A korábbi (beégetett) Block1 importban használt hozzárendelések.
const _aliases = <String, String>{
  'tempo420': 'block1_tempo_420',
  'lowbarguggolas': 'low_bar_squat',
  'bench': 'comp_bench',
  'lehuzasmagammelle': 'block1_lehuzas_magam_melle',
  'tarogatas': 'pec_deck',
  'bfrancia': 'ez_skull',
  'oldalemeles': 'lateral_raise',
  'deadlift': 'comp_deadlift',
  'szeleslehuzas': 'block1_szeles_lehuzas',
  'kalapacsb': 'hammer_curl',
  'squat': 'comp_squat',
  'chestpressalva': 'block1_chest_press_alva',
  'evezesszeles': 'block1_evezes_szeles',
  'hatsoval': 'rear_delt_fly',
  'cmbf': 'cmbf',
  'combh': 'combh',
};

/// Ezek a gyakorlatok a korábbi importból nem léteznek a beépített listában.
const _legacyCustom = <Exercise>[
  Exercise(id: 'block1_tempo_420', name: 'Tempo 4-2-0', nameHu: 'Tempo 4-2-0', category: 'main', lift: Lift.squat, variation: true),
  Exercise(id: 'block1_lehuzas_magam_melle', name: 'lehuzas magam melle', nameHu: 'lehuzas magam melle', equipment: 'cable', isCustom: true),
  Exercise(id: 'block1_szeles_lehuzas', name: 'szeles lehuzas', nameHu: 'szeles lehuzas', equipment: 'cable', isCustom: true),
  Exercise(id: 'block1_chest_press_alva', name: 'chest press alva', nameHu: 'chest press alva', equipment: 'machine', isCustom: true),
  Exercise(id: 'block1_evezes_szeles', name: 'evezes szeles', nameHu: 'evezes szeles', equipment: 'machine', isCustom: true),
];

String? guessLift(String name) {
  final n = normName(name);
  if (n.contains('squat') || n.contains('guggol')) return Lift.squat;
  if (n.contains('bench') || n.contains('fekvenyom')) return Lift.bench;
  if (n.contains('deadlift') || n.contains('felhuz')) return Lift.deadlift;
  return null;
}

/// Táblázatbeli gyakorlatnév → gyakorlat azonosító. Ismeretlen névhez új
/// (egyedi) gyakorlatot készít, amit a hívó elment.
class ExerciseResolver {
  final Map<String, Exercise> _byId;
  final Map<String, String> _byNorm = {};
  final List<Exercise> created = [];

  ExerciseResolver(Iterable<Exercise> known) : _byId = {for (final e in known) e.id: e} {
    for (final e in _legacyCustom) {
      _byId.putIfAbsent(e.id, () {
        created.add(e);
        return e;
      });
    }
    for (final e in _byId.values) {
      _byNorm.putIfAbsent(normName(e.name), () => e.id);
      if (e.nameHu.isNotEmpty) _byNorm.putIfAbsent(normName(e.nameHu), () => e.id);
    }
  }

  Exercise byId(String id) => _byId[id]!;

  Exercise resolve(String rawName) {
    final n = normName(rawName);
    final id = _aliases[n] ?? _byNorm[n];
    if (id != null && _byId.containsKey(id)) return _byId[id]!;
    final lift = guessLift(rawName);
    final e = Exercise(
      id: 'sheet_$n',
      name: rawName.trim(),
      nameHu: rawName.trim(),
      category: 'accessory',
      lift: lift,
      variation: lift != null,
      isCustom: true,
    );
    _byId[e.id] = e;
    _byNorm[n] = e.id;
    created.add(e);
    return e;
  }
}

// ───────────────────────────── cella-értelmezés ─────────────────────────────

(int?, int?) _repsKeepOrder(String raw) {
  final m = RegExp(r'^(\d+)(?:\s*-\s*(\d+))?').firstMatch(raw.trim());
  if (m == null) return (null, null);
  final a = int.parse(m.group(1)!);
  return (a, m.group(2) == null ? a : int.parse(m.group(2)!));
}

final _markerRe = RegExp(r'^\s*(top\s*set|top|back\s*-?\s*off|bo|amrap|warm\s*-?\s*up|meleg[ií]t[őo])\b[\s:,;.\-]*', caseSensitive: false);

String _markerType(String m) {
  final k = m.toLowerCase().replaceAll(RegExp(r'[\s\-]'), '');
  if (k.startsWith('top')) return SetType.top;
  if (k.startsWith('back') || k == 'bo') return SetType.backoff;
  if (k.startsWith('warm') || k.startsWith('meleg')) return SetType.warmup;
  return 'amrap';
}

/// Egy sor (egy hét) a tervből → PrescribedSet.
PrescribedSet parseCell(SheetCell c, int week, int position) {
  var note = c.note;
  var type = SetType.working;
  var amrap = false;
  final mm = _markerRe.firstMatch(note);
  if (mm != null) {
    final t = _markerType(mm.group(1)!);
    if (t == 'amrap') {
      amrap = true;
    } else {
      type = t;
    }
    note = note.substring(mm.end).trim();
  }

  var repsRaw = c.reps.trim();
  if (RegExp(r'^(amrap|max)$', caseSensitive: false).hasMatch(repsRaw)) {
    amrap = true;
    repsRaw = '';
  } else if (repsRaw.endsWith('+')) {
    amrap = true;
    repsRaw = repsRaw.substring(0, repsRaw.length - 1);
  }
  final (repsMin, repsMax) = _repsKeepOrder(repsRaw);
  final noteParts = <String>[note];
  if (repsMin == null && repsRaw.isNotEmpty) noteParts.add('Ism: $repsRaw');

  var load = c.load.trim();
  var loadType = LoadType.free;
  double? weight, weightMax, rpeMin, rpeMax;
  final lower = load.toLowerCase();
  if (lower.isEmpty) {
    // nincs előírás
  } else if (RegExp(r'^(m|max)\s*([+\-]\s*)?\d*([.,]\d+)?$').hasMatch(lower)) {
    loadType = LoadType.max;
    if (lower != 'max') noteParts.add('Terhelés: $load');
  } else {
    // "@8", "rpe 8" → a meglévő "R8" jelölésre
    final norm = lower.replaceAllMapped(RegExp(r'(@|rpe)\s*(\d)'), (m) => 'r${m.group(2)}');
    final p = parsePrescription(norm);
    rpeMin = p.rpeMin;
    rpeMax = p.rpeMax;
    if (p.isPercent && p.weight != null) {
      loadType = LoadType.pct;
      weight = p.weight;
    } else if (p.weight != null) {
      loadType = LoadType.abs;
      weight = p.weight;
      weightMax = p.weightMax;
    } else if (p.rpeMin != null) {
      loadType = LoadType.rpe;
    } else {
      noteParts.add('Terhelés: $load');
    }
  }

  return PrescribedSet(
    weekIndex: week,
    position: position,
    sets: int.tryParse(c.sets) ?? 1,
    repsMin: repsMin,
    repsMax: repsMax,
    loadType: loadType,
    weight: weight,
    weightMax: weightMax,
    rpeMin: rpeMin,
    rpeMax: rpeMax,
    note: noteParts.where((e) => e.isNotEmpty).join(' · '),
    amrap: amrap,
    setType: type,
  );
}

bool _sameSet(PrescribedSet a, PrescribedSet b) =>
    a.repsMin == b.repsMin &&
    a.repsMax == b.repsMax &&
    a.loadType == b.loadType &&
    a.weight == b.weight &&
    a.weightMax == b.weightMax &&
    a.rpeMin == b.rpeMin &&
    a.rpeMax == b.rpeMax &&
    a.note == b.note &&
    a.amrap == b.amrap &&
    a.setType == b.setType;

/// Egymást követő azonos sorok összevonása (3 × "1×5 @185" → "3×5 @185").
List<PrescribedSet> _compress(List<PrescribedSet> list) {
  final out = <PrescribedSet>[];
  for (final s in list) {
    if (out.isNotEmpty && _sameSet(out.last, s)) {
      out.last.sets += s.sets;
    } else {
      out.add(s);
    }
  }
  for (var i = 0; i < out.length; i++) {
    out[i].position = i;
  }
  return out;
}

/// Főemelés: a legnehezebb sor top set, utána a könnyebbek back-off
/// (csak ha semmi nincs kézzel megjelölve).
void _autoTopBackoff(List<PrescribedSet> sets) {
  if (sets.length < 2 || sets.any((s) => s.setType != SetType.working || s.amrap)) return;
  double? w(PrescribedSet s) => s.loadType == LoadType.abs ? s.weight : null;
  if (sets.any((s) => w(s) == null)) return;
  var h = 0;
  for (var i = 1; i < sets.length; i++) {
    if (w(sets[i])! > w(sets[h])!) h = i;
  }
  if (h == sets.length - 1) return;
  final lighter = [for (var i = h + 1; i < sets.length; i++) if (w(sets[i])! < w(sets[h])!) i];
  if (lighter.isEmpty) return;
  sets[h].setType = SetType.top;
  for (final i in lighter) {
    sets[i].setType = SetType.backoff;
  }
}

const huDays = {1: 'Hétfő', 2: 'Kedd', 3: 'Szerda', 4: 'Csütörtök', 5: 'Péntek', 6: 'Szombat', 7: 'Vasárnap'};

/// A Block-N fül → ProgramBlock. [existing] esetén a blokk és a napok azonosítói
/// megmaradnak (a korábbi edzések hivatkozásai épek maradnak).
ProgramBlock buildBlock(SheetPlan plan, ExerciseResolver resolver, {ProgramBlock? existing}) {
  final days = <ProgramDay>[];
  for (var di = 0; di < plan.days.length; di++) {
    final d = plan.days[di];
    final old = existing?.days.where((x) => x.weekday == d.weekday).firstOrNull;

    // gyakorlat-csoportok: egymást követő, azonos nevű sorok
    final groups = <List<SheetLine>>[];
    String? lastKey;
    for (final line in d.lines) {
      if (line.cells.isEmpty) continue;
      final key = normName((line.cell(0) ?? line.cells.first).name);
      if (groups.isNotEmpty && key == lastKey) {
        groups.last.add(line);
      } else {
        groups.add([line]);
      }
      lastKey = key;
    }

    final exs = <ProgramExercise>[];
    for (var gi = 0; gi < groups.length; gi++) {
      final g = groups[gi];
      final first = g.first.cell(0) ?? g.first.cells.first;
      final ex = resolver.resolve(first.name);
      final sets = <PrescribedSet>[];
      for (var w = 0; w < plan.weeks; w++) {
        final week = <PrescribedSet>[];
        for (final line in g) {
          final c = line.cell(w);
          if (c == null) continue;
          final ps = parseCell(c, w, week.length);
          if (normName(c.name) != normName(first.name) && c.name.isNotEmpty) {
            ps.note = [ps.note, 'Gyakorlat: ${c.name}'].where((e) => e.isNotEmpty).join(' · ');
          }
          week.add(ps);
        }
        final compressed = _compress(week);
        if (ex.category == 'main') _autoTopBackoff(compressed);
        sets.addAll(compressed);
      }
      final oldEx = old != null && gi < old.exercises.length ? old.exercises[gi] : null;
      exs.add(ProgramExercise(
        id: oldEx != null && oldEx.exerciseId == ex.id ? oldEx.id : null,
        exerciseId: ex.id,
        position: gi,
        sets: sets,
      ));
    }
    days.add(ProgramDay(
      id: old?.id,
      name: huDays[d.weekday] ?? d.name,
      weekday: d.weekday,
      tag: old?.tag ?? '',
      position: di,
      exercises: exs,
    ));
  }
  return ProgramBlock(
    id: existing?.id,
    name: plan.sheet,
    startDate: plan.startDate,
    weekCount: plan.weeks,
    days: days,
  );
}
