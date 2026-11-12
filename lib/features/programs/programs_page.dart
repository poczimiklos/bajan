import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/models.dart';
import '../../data/sample_programs.dart';
import '../../providers/providers.dart';

class _Sample {
  final String name;
  final String blurb;
  final Program Function() build;
  const _Sample(this.name, this.blurb, this.build);
}

final _samples = <_Sample>[
  const _Sample('e2.0 · Coach program',
      'Your Tue/Thu/Sat 5-week block (Block 1, from 20 Oct 2026) with the coach\'s weights.', coachBlockProgram),
  const _Sample('Starting Strength', 'Novice linear progression, A/B workouts three times a week.', startingStrength),
  const _Sample('5/3/1', 'Wendler 4-week wave on Training Max, with Boring But Big volume.', wendler531),
  const _Sample('Texas Method', 'Volume / Recovery / Intensity week built around a weekly 5-rep PR.', texasMethod),
];

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
        final names = programs.map((p) => p.name).toSet();
        final available = _samples.where((s) => !names.contains(s.name)).toList();
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
          if (programs.isEmpty)
            AppCard(
                child: Text('No programs yet. Add a sample below or create your own.',
                    style: TextStyle(color: context.muted)))
          else
            for (final p in programs)
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
          if (available.isNotEmpty) ...[
            const SectionTitle('Sample programs'),
            for (final s in available)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(s.blurb, style: TextStyle(color: context.muted)),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.download, size: 18),
                        label: const Text('Add to my programs'),
                        onPressed: () async {
                          final p = s.build();
                          await ref.read(programRepoProvider).save(p);
                          refreshAll(ref);
                          if (context.mounted) context.push('/program/${p.id}');
                        },
                      ),
                    ),
                  ]),
                ),
              ),
          ],
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
    final p = emptyCustom(name);
    await ref.read(programRepoProvider).save(p);
    refreshAll(ref);
    if (context.mounted) context.push('/program/${p.id}');
  }
}
