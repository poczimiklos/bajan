import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../data/models.dart';
import '../../../providers/providers.dart';

class TrainingMaxSection extends ConsumerWidget {
  const TrainingMaxSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const SectionTitle('Training max (for % programs)'),
      AppCard(
        child: Column(children: [
          Text('Used by 5/3/1, Texas Method and other %-based prescriptions. 0 = automatic (90% of your current e1RM).',
              style: TextStyle(color: context.muted, fontSize: 12)),
          const SizedBox(height: 8),
          for (final l in Lift.all)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(children: [
                SizedBox(width: 90, child: Text(Lift.label(l))),
                Expanded(
                  child: TextFormField(
                    key: ValueKey('tm-$l-${s.unit}'),
                    initialValue:
                        (s.trainingMax[l] ?? 0) > 0 ? fmtNum(s.toDisplay(s.trainingMax[l]!), decimals: 2) : '',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(hintText: 'auto', suffixText: s.unitLabel),
                    onChanged: (v) {
                      final shown = parseNum(v);
                      notifier.update(
                          (x) => x.copyWith(trainingMax: {...x.trainingMax, l: shown == null ? 0 : x.toKg(shown)}));
                    },
                  ),
                ),
              ]),
            ),
        ]),
      ),
    ]);
  }
}
