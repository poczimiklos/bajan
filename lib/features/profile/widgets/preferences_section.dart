import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/common.dart';
import '../../../domain/e1rm.dart';
import '../../../providers/providers.dart';
import 'choice_row.dart';

class PreferencesSection extends ConsumerWidget {
  const PreferencesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // ── preferences ──
      const SectionTitle('Beállítások'),
      AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ChoiceRow<String>('Súlymérték', s.unit, const {'kg': 'kg', 'lb': 'lb'},
              (v) => notifier.update((x) => x.copyWith(unit: v))),
          ChoiceRow<E1rmFormula>(
            '1RM becslési képlet',
            s.formula,
            {for (final f in E1rmFormula.values) f: f.label},
            (v) => notifier.update((x) => x.copyWith(formula: v)),
          ),
          ChoiceRow<String>('Intenzitás skála', s.rpeScale, const {'rpe': 'RPE', 'rir': 'RIR'},
              (v) => notifier.update((x) => x.copyWith(rpeScale: v))),
          ChoiceRow<String>('Téma', s.theme, const {'dark': 'Sötét', 'light': 'Világos', 'system': 'Rendszer'},
              (v) => notifier.update((x) => x.copyWith(theme: v))),
          ChoiceRow<String>('Nem (DOTS-hoz)', s.sex, const {'m': 'Férfi', 'f': 'Nő'},
              (v) => notifier.update((x) => x.copyWith(sex: v))),
        ]),
      ),
    ]);
  }
}
