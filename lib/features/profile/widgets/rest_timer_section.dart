import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/common.dart';
import '../../../providers/providers.dart';
import 'choice_row.dart';

class RestTimerSection extends ConsumerWidget {
  const RestTimerSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const SectionTitle('Rest timer & bar'),
      AppCard(
        child: Column(children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Start automatically when a set is completed'),
            value: s.autoRest,
            onChanged: (v) => notifier.update((x) => x.copyWith(autoRest: v)),
          ),
          Row(children: [
            const Expanded(child: Text('Default rest')),
            IconButton(
              onPressed: () => notifier.update((x) => x.copyWith(restSeconds: (x.restSeconds - 15).clamp(15, 900))),
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text('${s.restSeconds ~/ 60}:${(s.restSeconds % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            IconButton(
              onPressed: () => notifier.update((x) => x.copyWith(restSeconds: (x.restSeconds + 15).clamp(15, 900))),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ]),
          ChoiceRow<double>('Barbell weight', s.barKg, {20.0: '20 kg', 15.0: '15 kg'},
              (v) => notifier.update((x) => x.copyWith(barKg: v))),
        ]),
      ),
    ]);
  }
}
