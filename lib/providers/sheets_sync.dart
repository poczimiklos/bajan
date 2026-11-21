import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/checkin.dart';
import '../data/models.dart';
import '../data/repositories/checkin_repository.dart';
import '../data/sheets/log_rows.dart';
import '../data/sheets/sheet_importer.dart';
import '../data/sheets/sheet_plan.dart';
import '../data/sheets/sheets_client.dart';
import 'bootstrap_provider.dart';
import 'data_providers.dart';
import 'infrastructure.dart';
import 'settings_provider.dart';

const _kUrl = 'sheets_url';
const _kToken = 'sheets_token';

final checkInRepoProvider = Provider<CheckInRepository>((ref) => CheckInRepository(ref.watch(appDatabaseProvider)));

// ───────────────────────────── beállítások ─────────────────────────────

class SheetsConfig {
  final String url;
  final String token;
  const SheetsConfig({this.url = '', this.token = ''});
  bool get configured => url.trim().isNotEmpty && token.trim().isNotEmpty;
}

class SheetsConfigNotifier extends Notifier<SheetsConfig> {
  @override
  SheetsConfig build() {
    final p = ref.watch(sharedPrefsProvider);
    return SheetsConfig(url: p.getString(_kUrl) ?? '', token: p.getString(_kToken) ?? '');
  }

  Future<void> save(String url, String token) async {
    final p = ref.read(sharedPrefsProvider);
    await p.setString(_kUrl, url.trim());
    await p.setString(_kToken, token.trim());
    state = SheetsConfig(url: url.trim(), token: token.trim());
  }
}

final sheetsConfigProvider = NotifierProvider<SheetsConfigNotifier, SheetsConfig>(SheetsConfigNotifier.new);

// ───────────────────────────── szinkron ─────────────────────────────

class SheetsSyncState {
  final bool busy;
  final DateTime? lastPush;
  final DateTime? lastPull;
  final String? error;
  final int pending;
  const SheetsSyncState({this.busy = false, this.lastPush, this.lastPull, this.error, this.pending = 0});

  SheetsSyncState copyWith({
    bool? busy,
    DateTime? lastPush,
    DateTime? lastPull,
    Object? error = _keep,
    int? pending,
  }) =>
      SheetsSyncState(
        busy: busy ?? this.busy,
        lastPush: lastPush ?? this.lastPush,
        lastPull: lastPull ?? this.lastPull,
        error: identical(error, _keep) ? this.error : error as String?,
        pending: pending ?? this.pending,
      );
}

const Object _keep = Object();
const _pullEvery = Duration(minutes: 5);
const _retryAfterFail = Duration(seconds: 45);
const _outboxEntities = "('workout','checkin')";

class SheetsSyncNotifier extends Notifier<SheetsSyncState> {
  bool _running = false;
  DateTime? _failedAt;

  @override
  SheetsSyncState build() => const SheetsSyncState();

  SheetsClient? _client() {
    final c = ref.read(sheetsConfigProvider);
    return c.configured ? SheetsClient(c.url, c.token) : null;
  }

  /// Időzítő / alkalmazás-visszatérés hívja: csak akkor dolgozik, ha van mit.
  Future<void> tick({bool forcePull = false}) async {
    if (_client() == null || _running) return;
    final f = _failedAt;
    if (f != null && DateTime.now().difference(f) < _retryAfterFail && !forcePull) return;
    final pending = await _pendingCount();
    final pullDue = state.lastPull == null || DateTime.now().difference(state.lastPull!) >= _pullEvery;
    if (pending == 0 && !pullDue && !forcePull) {
      if (state.pending != 0) state = state.copyWith(pending: 0);
      return;
    }
    await _run(forcePull: forcePull);
  }

  /// „Szinkron most" gomb: mindent újraolvas.
  Future<void> syncNow() => _run(forcePull: true, forceImport: true);

  Future<String> testConnection() async {
    final c = _client();
    if (c == null) throw const SheetsException('Add meg az URL-t és a tokent');
    final r = await c.get('ping');
    final b = await c.get('blocks');
    final blocks = (b['blocks'] as List? ?? const []).length;
    return '${r['title']} · $blocks Block fül';
  }

  Future<int> _pendingCount() async {
    final db = await ref.read(appDatabaseProvider).db;
    final r = await db.rawQuery('SELECT COUNT(*) AS n FROM sync_outbox WHERE entity IN $_outboxEntities');
    return (r.first['n'] as int?) ?? 0;
  }

  Future<void> _run({bool forcePull = false, bool forceImport = false}) async {
    final client = _client();
    if (client == null || _running) return;
    _running = true;
    state = state.copyWith(busy: true);
    try {
      await ref.read(bootstrapProvider.future);
      await _push(client);
      final pullDue = state.lastPull == null || DateTime.now().difference(state.lastPull!) >= _pullEvery;
      if (forcePull || pullDue) await _pull(client, force: forceImport);
      _failedAt = null;
      state = state.copyWith(error: null);
    } on SheetsException catch (e) {
      _failedAt = DateTime.now();
      state = state.copyWith(error: e.message);
    } catch (e) {
      _failedAt = DateTime.now();
      state = state.copyWith(error: '$e');
    } finally {
      _running = false;
      state = state.copyWith(busy: false, pending: await _pendingCount());
    }
  }

  // ── napló / check-in → táblázat ──

  Future<void> _push(SheetsClient client) async {
    final db = await ref.read(appDatabaseProvider).db;
    final rows = await db.query('sync_outbox', where: 'entity IN $_outboxEntities', orderBy: 'id');
    if (rows.isEmpty) return;
    final maxId = rows.last['id'] as int;

    final wOp = <String, String>{};
    final cIds = <String>{};
    for (final r in rows) {
      final id = r['entity_id'] as String;
      if (r['entity'] == 'workout') {
        wOp[id] = r['op'] as String;
      } else {
        cIds.add(id);
      }
    }

    final workouts = ref.read(workoutRepoProvider);
    final programs = ref.read(programRepoProvider);
    final formula = ref.read(settingsProvider).formula;
    final blockCache = <String, ProgramBlock?>{};

    Future<ProgramBlock?> blockOf(String? id) async {
      if (id == null) return null;
      if (blockCache.containsKey(id)) return blockCache[id];
      final p = await programs.loadByBlock(id);
      return blockCache[id] = p?.blocks.where((b) => b.id == id).firstOrNull;
    }

    final outWorkouts = <Map<String, Object?>>[];
    final outSets = <Map<String, Object?>>[];
    final deletes = <String>[];
    for (final e in wOp.entries) {
      final w = e.value == 'delete' ? null : await workouts.load(e.key);
      if (w == null) {
        deletes.add(e.key);
        continue;
      }
      if (w.status != 'done') continue;
      final block = await blockOf(w.programBlockId);
      final x =
          exportWorkout(w, block: block?.name ?? '', week: weekNumber(block?.startDate, w.date), formula: formula);
      outWorkouts.add(x.workout);
      outSets.addAll(x.sets);
    }

    final outCheckins = <Map<String, Object?>>[];
    final checkins = ref.read(checkInRepoProvider);
    for (final id in cIds) {
      final d = DateTime.tryParse(id);
      if (d == null) continue;
      final c = await checkins.forDay(d);
      if (c != null && !c.isEmpty) outCheckins.add(checkInRow(c));
    }

    if (outWorkouts.isNotEmpty || outSets.isNotEmpty || outCheckins.isNotEmpty || deletes.isNotEmpty) {
      await client.push({
        'workouts': outWorkouts,
        'sets': outSets,
        'checkins': outCheckins,
        'deleteWorkouts': deletes,
      });
      state = state.copyWith(lastPush: DateTime.now());
    }
    await db.delete('sync_outbox', where: 'id <= ? AND entity IN $_outboxEntities', whereArgs: [maxId]);
  }

  // ── terv ← táblázat ──

  Future<void> _pull(SheetsClient client, {bool force = false}) async {
    final res = SheetPlans.fromJson(await client.get('plans'));
    final importer =
        SheetImporter(ref.read(programRepoProvider), ref.read(exerciseRepoProvider), ref.read(sharedPrefsProvider));
    final r = await importer.importAll(res, force: force);

    final current = ref.read(settingsProvider).activeBlockId;
    final cand = r.activeCandidate;
    if (cand != null &&
        cand != current &&
        (current == null || !r.allBlockIds.contains(current) || r.sheetBlockIds.contains(current))) {
      await ref.read(settingsProvider.notifier).update((s) => s.copyWith(activeBlockId: cand));
    }
    if (r.changed || force) {
      ref
        ..invalidate(programsProvider)
        ..invalidate(programDetailProvider)
        ..invalidate(activePlanProvider)
        ..invalidate(exercisesProvider);
    }
    state = state.copyWith(lastPull: DateTime.now());
  }
}

final sheetsSyncProvider = NotifierProvider<SheetsSyncNotifier, SheetsSyncState>(SheetsSyncNotifier.new);

// ───────────────────────────── napi check-in ─────────────────────────────

/// A mai check-in; módosításkor azonnal ment és sorba állítja a táblázatba írást.
class TodayCheckInNotifier extends Notifier<CheckIn> {
  Timer? _debounce;
  bool _disposed = false;

  @override
  CheckIn build() {
    final today = CheckIn.empty(DateTime.now());
    ref.onDispose(() {
      _disposed = true;
      _debounce?.cancel();
    });
    Future<void>(() async {
      final saved = await ref.read(checkInRepoProvider).forDay(DateTime.now());
      if (!_disposed && saved != null) state = saved;
    });
    return today;
  }

  void update(CheckIn Function(CheckIn) change) {
    final now = DateTime.now();
    if (state.id != dayKey(now)) state = CheckIn.empty(now);
    state = change(state);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (!state.isEmpty) ref.read(checkInRepoProvider).save(state);
    });
  }
}

final todayCheckInProvider = NotifierProvider<TodayCheckInNotifier, CheckIn>(TodayCheckInNotifier.new);
