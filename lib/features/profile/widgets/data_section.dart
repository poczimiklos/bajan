import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/common.dart';
import '../../../providers/providers.dart';
import 'backup_actions.dart';

class DataSection extends ConsumerWidget {
  const DataSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(syncStatusProvider).value;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // ── data ──
      const SectionTitle('Data'),
      AppCard(
        padding: EdgeInsets.zero,
        child: Column(children: [
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Export / back up data'),
            subtitle: const Text('JSON file with all workouts, programs and records'),
            onTap: () => exportBackup(context, ref),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restore from backup'),
            subtitle: const Text('Replaces all data on this device'),
            onTap: () => restoreBackup(context, ref),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.cloud_sync_outlined),
            title: Text(sync == null
                ? 'Cloud sync'
                : sync.configured
                    ? 'Cloud sync · ${sync.pending} change${sync.pending == 1 ? '' : 's'} pending'
                    : 'Cloud sync not configured (${sync.pending} change${sync.pending == 1 ? '' : 's'} queued locally)'),
            subtitle: const Text('Local data is always saved first; sync runs in the background layer'),
            onTap: () async {
              final n = await ref.read(syncServiceProvider).syncNow();
              ref.invalidate(syncStatusProvider);
              if (context.mounted) {
                snack(
                    context,
                    ref.read(syncServiceProvider).remote.isConfigured
                        ? 'Synced $n changes'
                        : 'No backend configured – see README.');
              }
            },
          ),
        ]),
      ),
    ]);
  }
}
