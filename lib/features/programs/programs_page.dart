import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/models.dart';
import '../../providers/providers.dart';

class ProgramsPage extends ConsumerWidget {
  const ProgramsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(programsProvider);
    final activeBlock = ref.watch(settingsProvider.select((s) => s.activeBlockId));
    return AsyncView<List<Program>>(
      value: async,
      onRetry: () => ref.invalidate(programsProvider),
      data: (programs) {
        final visiblePrograms = programs.where((program) => !program.isSample).toList();
        return ListView(padding: const EdgeInsets.all(16), children: [
          Row(children: [
            const Expanded(child: Text('Programs', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800))),
            IconButton.filled(
              onPressed: () => _create(context, ref),
              icon: const Icon(Icons.add),
              tooltip: 'New program',
            ),
          ]),
          const SectionTitle('My programs'),
          if (visiblePrograms.isEmpty)
            AppCard(
                child: Text('No programs yet. Create one to start planning your training.',
                    style: TextStyle(color: context.muted)))
          else
            for (final p in visiblePrograms)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  onTap: () => context.push('/program/${p.id}'),
                  child: Row(children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Flexible(
                              child: Text(p.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))),
                          if (p.blocks.any((b) => b.id == activeBlock)) ...[
                            const SizedBox(width: 8),
                            Chip(
                                label: const Text('Active'),
                                visualDensity: VisualDensity.compact,
                                backgroundColor: context.accent.withValues(alpha: 0.25)),
                          ],
                        ]),
                        const SizedBox(height: 4),
                        Text(
                          '${p.blocks.length} block${p.blocks.length == 1 ? '' : 's'} · ${p.blocks.fold<int>(0, (a, b) => a + b.days.length)} training days',
                          style: TextStyle(color: context.muted, fontSize: 12),
                        ),
                      ]),
                    ),
                    const Icon(Icons.chevron_right),
                  ]),
                ),
              ),
          const SizedBox(height: 24),
        ]);
      },
    );
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final c = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('New program'),
        content: TextField(controller: c, autofocus: true, decoration: const InputDecoration(labelText: 'Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(d, c.text.trim()), child: const Text('Create')),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    final p = Program(name: name, blocks: [ProgramBlock(name: 'Block 1', weekCount: 4)]);
    await ref.read(programRepoProvider).save(p);
    refreshAll(ref);
    if (context.mounted) context.push('/program/${p.id}');
  }
}
