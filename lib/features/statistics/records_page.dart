import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/models.dart';
import '../../providers/providers.dart';
import '../training/widgets/pr_dialog.dart';

/// All detected personal records, grouped by exercise.
class RecordsPage extends ConsumerWidget {
  const RecordsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Personal records')),
      body: AsyncView<List<PersonalRecord>>(
        value: ref.watch(recordsProvider),
        onRetry: () => ref.invalidate(recordsProvider),
        data: (all) {
          if (all.isEmpty) {
            return const EmptyState(
              icon: Icons.emoji_events_outlined,
              title: 'No records yet',
              message: 'Records are detected automatically when you finish a workout.',
            );
          }
          final byExercise = <String, List<PersonalRecord>>{};
          for (final r in all) {
            (byExercise[r.exerciseName] ??= []).add(r);
          }
          final names = byExercise.keys.toList()..sort();
          return ListView(padding: const EdgeInsets.all(16), children: [
            for (final n in names) ...[
              SectionTitle(n),
              // Show only the current best of each kind (+ rep records at weights).
              for (final r in _currentBests(byExercise[n]!))
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(r.kindLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
                          Text(
                            '${DateFormat('d MMM yyyy').format(r.date)}${r.previous == null ? '' : ' · prev ${r.kind == 'reps' ? fmtNum(r.previous, decimals: 0) : fmtNum(settings.toDisplay(r.previous!))}'}',
                            style: TextStyle(color: context.muted, fontSize: 12),
                          ),
                        ]),
                      ),
                      Text(prValueText(r, settings),
                          style: TextStyle(color: context.accent, fontWeight: FontWeight.w800)),
                    ]),
                  ),
                ),
            ],
          ]);
        },
      ),
    );
  }

  List<PersonalRecord> _currentBests(List<PersonalRecord> list) {
    final best = <String, PersonalRecord>{};
    for (final r in list) {
      final key = r.kind == 'reps' ? 'reps-${r.weight}' : r.kind;
      final cur = best[key];
      if (cur == null || r.value > cur.value) best[key] = r;
    }
    final out = best.values.toList();
    // Heaviest, e1RM first, then rep records by weight (heavy first), top 4.
    out.sort((a, b) {
      int rank(PersonalRecord r) => switch (r.kind) { 'weight' => 0, 'e1rm' => 1, _ => 2 };
      final c = rank(a).compareTo(rank(b));
      return c != 0 ? c : (b.weight ?? 0).compareTo(a.weight ?? 0);
    });
    final main = out.where((r) => r.kind != 'reps').toList();
    final reps = out.where((r) => r.kind == 'reps').take(4).toList();
    return [...main, ...reps];
  }
}
