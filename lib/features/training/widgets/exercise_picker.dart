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
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Gyakorlat keresése'),
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
                  ('all', 'Mind'),
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
                      title: 'Nincs találat',
                      message: 'Próbálj másik keresést, vagy hozz létre egyedi gyakorlatot.');
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
                label: const Text('Egyedi gyakorlat létrehozása'),
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
        title: const Text('Új gyakorlat'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, autofocus: true, decoration: const InputDecoration(labelText: 'Név')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: category,
            decoration: const InputDecoration(labelText: 'Kategória'),
            items: const [
              DropdownMenuItem(value: 'main', child: Text('Főemelés')),
              DropdownMenuItem(value: 'accessory', child: Text('Kiegészítő')),
            ],
            onChanged: (v) => setS(() => category = v ?? 'accessory'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            initialValue: lift,
            decoration: const InputDecoration(labelText: 'Statisztikában ide számít'),
            items: const [
              DropdownMenuItem(value: null, child: Text('Egyik sem')),
              DropdownMenuItem(value: 'squat', child: Text('Guggolás')),
              DropdownMenuItem(value: 'bench', child: Text('Fekvenyomás')),
              DropdownMenuItem(value: 'deadlift', child: Text('Felhúzás')),
            ],
            onChanged: (v) => setS(() => lift = v),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Mégse')),
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
            child: const Text('Létrehozás'),
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
