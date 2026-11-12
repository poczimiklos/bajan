import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/common.dart';
import '../../../data/models.dart';
import '../../../providers/providers.dart';

Future<void> showEditProfileDialog(BuildContext context, WidgetRef ref) async {
  final s = ref.read(settingsProvider);
  final name = TextEditingController(text: s.username);
  final exp = TextEditingController(text: s.experience);
  final goals = TextEditingController(text: s.goals);
  final ok = await showDialog<bool>(
    context: context,
    builder: (d) => AlertDialog(
      title: const Text('Edit profile'),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Username')),
          const SizedBox(height: 12),
          TextField(
              controller: exp,
              decoration: const InputDecoration(labelText: 'Training experience', hintText: 'e.g. 3 years')),
          const SizedBox(height: 12),
          TextField(
              controller: goals,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Current goals')),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(d, true), child: const Text('Save')),
      ],
    ),
  );
  if (ok != true) return;
  await ref.read(settingsProvider.notifier).update(
        (x) => x.copyWith(
            username: name.text.trim().isEmpty ? 'Lifter' : name.text.trim(),
            experience: exp.text.trim(),
            goals: goals.text.trim()),
      );
}

Future<void> showLogBodyweightDialog(BuildContext context, WidgetRef ref) async {
  final s = ref.read(settingsProvider);
  final c = TextEditingController();
  final v = await showDialog<double>(
    context: context,
    builder: (d) => AlertDialog(
      title: const Text('Log bodyweight'),
      content: TextField(
        controller: c,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(suffixText: s.unitLabel),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(d), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(d, parseNum(c.text)), child: const Text('Save')),
      ],
    ),
  );
  if (v == null || v <= 0) return;
  await ref.read(bodyweightRepoProvider).add(BodyweightEntry(date: DateTime.now(), kg: s.toKg(v)));
  refreshAll(ref);
}
