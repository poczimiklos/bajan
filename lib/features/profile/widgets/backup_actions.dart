import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/common.dart';
import '../../../providers/providers.dart';
import 'package:share_plus/share_plus.dart';

Future<void> exportBackup(BuildContext context, WidgetRef ref) async {
  try {
    final f = await ref.read(backupServiceProvider).exportToFile();
    await SharePlus.instance.share(ShareParams(files: [XFile(f.path)], text: 'Powerlifting Tracker Excel data export'));
  } catch (e) {
    if (context.mounted) snack(context, 'Az exportálás nem sikerült: $e');
  }
}

Future<void> restoreBackup(BuildContext context, WidgetRef ref) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (d) => AlertDialog(
      title: const Text('Visszaállítod a mentést?'),
      content: const Text('Az eszközön lévő összes edzés, terv és rekord le lesz cserélve.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Mégse')),
        TextButton(onPressed: () => Navigator.pop(d, true), child: const Text('Visszaállítás')),
      ],
    ),
  );
  if (ok != true) return;
  try {
    final res = await FilePicker.pickFiles(type: FileType.any);
    final path = res.isEmpty ? null : res.first.path;
    if (path == null) return;
    final json = utf8.decode(await File(path).readAsBytes());
    await ref.read(backupServiceProvider).restoreFromJson(json);
    await ref.read(exerciseRepoProvider).seedIfNeeded();
    ref.read(workoutEditorProvider.notifier).closeEditor();
    await ref.read(workoutEditorProvider.notifier).restoreActive();
    refreshAll(ref);
    if (context.mounted) snack(context, 'Mentés visszaállítva.');
  } catch (e) {
    if (context.mounted) snack(context, 'A visszaállítás nem sikerült: $e');
  }
}
