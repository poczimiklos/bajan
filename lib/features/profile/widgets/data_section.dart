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
      const SectionTitle('Adatok'),
      AppCard(
        padding: EdgeInsets.zero,
        child: Column(children: [
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Adatok exportálása Excelbe'),
            subtitle: const Text('Excel fájl az edzésekkel, tervekkel és rekordokkal'),
            onTap: () => exportBackup(context, ref),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Visszaállítás mentésből'),
            subtitle: const Text('JSON mentést állít vissza, és lecseréli az eszközön lévő összes adatot'),
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
            subtitle: const Text('Az adat mindig először helyben mentődik; a szinkron a háttérben fut'),
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
