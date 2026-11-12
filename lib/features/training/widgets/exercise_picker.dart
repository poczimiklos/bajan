import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../data/models.dart';
import '../../../providers/providers.dart';

/// Bottom sheet that returns the chosen exercise (or null).
Future<Exercise?> pickExercise(BuildContext context) {
  return showModalBottomSheet<Exercise>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _PickerSheet(),
  );
}

class _PickerSheet extends ConsumerStatefulWidget {
  const _PickerSheet();
  @override
  ConsumerState<_PickerSheet> createState() => _PickerSheetState();
}

class _PickerSheetState extends ConsumerState<_PickerSheet> {
  String _query = '';
  String _filter = 'all'; // all | main | accessory | custom

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(exercisesProvider);
    final height = MediaQuery.of(context).size.height * 0.85;
    return SizedBox(
      height: height,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search exercises'),
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final f in const [
                  ('all', 'All'),
                  ('main', 'Main lifts'),
                  ('accessory', 'Accessories'),
                  ('custom', 'Custom')
                ])
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(f.$2),
                      selected: _filter == f.$1,
                      onSelected: (_) => setState(() => _filter = f.$1),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: AsyncView<List<Exercise>>(
              value: async,
              data: (list) {
                final shown = list.where((e) {
                  final okFilter = switch (_filter) {
                    'main' => e.category == 'main',
                    'accessory' => e.category == 'accessory',
                    'custom' => e.isCustom,
                    _ => true,
                  };
                  final okQuery = _query.isEmpty ||
                      e.name.toLowerCase().contains(_query) ||
                      e.nameHu.toLowerCase().contains(_query);
                  return okFilter && okQuery;
                }).toList();
                if (shown.isEmpty) {
                  return const EmptyState(
                      icon: Icons.search_off,
                      title: 'No exercises found',
                      message: 'Try another search or create a custom exercise.');
                }
                return ListView.builder(
                  itemCount: shown.length,
                  itemBuilder: (c, i) {
                    final e = shown[i];
                    return ListTile(
                      title: Text(e.name),
                      subtitle: Text(
                          [
                            if (e.nameHu.isNotEmpty && e.nameHu != e.name) e.nameHu,
                            if (e.lift != null) Lift.label(e.lift!),
                          ].join(' · '),
                          style: TextStyle(color: context.muted)),
                      trailing: e.category == 'main' ? Icon(Icons.star, size: 16, color: context.accent) : null,
                      onTap: () => Navigator.pop(context, e),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Create custom exercise'),
                onPressed: () async {
                  final created = await _createCustom(context, ref);
                  if (created != null && context.mounted) Navigator.pop(context, created);
                },
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

Future<Exercise?> _createCustom(BuildContext context, WidgetRef ref) async {
  final name = TextEditingController();
  String category = 'accessory';
  String? lift;
  final result = await showDialog<Exercise>(
    context: context,
    builder: (c) => StatefulBuilder(
      builder: (c, setS) => AlertDialog(
        title: const Text('New exercise'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, autofocus: true, decoration: const InputDecoration(labelText: 'Name')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: category,
            decoration: const InputDecoration(labelText: 'Category'),
            items: const [
              DropdownMenuItem(value: 'main', child: Text('Main lift')),
              DropdownMenuItem(value: 'accessory', child: Text('Accessory')),
            ],
            onChanged: (v) => setS(() => category = v ?? 'accessory'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            initialValue: lift,
            decoration: const InputDecoration(labelText: 'Counts towards (statistics)'),
            items: const [
              DropdownMenuItem(value: null, child: Text('None')),
              DropdownMenuItem(value: 'squat', child: Text('Squat')),
              DropdownMenuItem(value: 'bench', child: Text('Bench press')),
              DropdownMenuItem(value: 'deadlift', child: Text('Deadlift')),
            ],
            onChanged: (v) => setS(() => lift = v),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(80, 44)),
            onPressed: () {
              final n = name.text.trim();
              if (n.isEmpty) return;
              Navigator.pop(
                c,
                Exercise(
                    id: newId(),
                    name: n,
                    category: category,
                    lift: lift,
                    variation: category != 'main',
                    isCustom: true),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    ),
  );
  if (result == null) return null;
  await ref.read(exerciseRepoProvider).save(result);
  ref.invalidate(exercisesProvider);
  return result;
}
