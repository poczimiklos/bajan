import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../data/models.dart';
import '../../../providers/providers.dart';
import 'profile_dialogs.dart';

class BodyweightSection extends ConsumerWidget {
  const BodyweightSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final bw = ref.watch(bodyweightProvider).value ?? const <BodyweightEntry>[];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // ── bodyweight ──
      SectionTitle('Bodyweight',
          trailing: TextButton.icon(
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Log'),
            onPressed: () => showLogBodyweightDialog(context, ref),
          )),
      if (bw.isEmpty)
        AppCard(
            child: Text('Log your bodyweight to get relative strength scores (DOTS).',
                style: TextStyle(color: context.muted)))
      else
        for (final e in bw.take(5))
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(children: [
                Expanded(child: Text(DateFormat('EEE d MMM yyyy').format(e.date))),
                Text('${fmtNum(s.toDisplay(e.kg))} ${s.unitLabel}',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () async {
                    await ref.read(bodyweightRepoProvider).delete(e.id);
                    refreshAll(ref);
                  },
                ),
              ]),
            ),
          ),
    ]);
  }
}
