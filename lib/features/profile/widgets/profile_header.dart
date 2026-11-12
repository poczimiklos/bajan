import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../data/models.dart';
import '../../../providers/providers.dart';
import 'profile_dialogs.dart';

class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final bw = ref.watch(bodyweightProvider).value ?? const <BodyweightEntry>[];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      AppCard(
        child: Row(children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: context.accent.withValues(alpha: 0.25),
            child: Text(s.username.isEmpty ? '?' : s.username[0].toUpperCase(),
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: context.accent)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.username, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              Text(
                bw.isEmpty
                    ? 'No bodyweight logged'
                    : '${fmtNum(s.toDisplay(bw.first.kg))} ${s.unitLabel} · ${DateFormat('d MMM').format(bw.first.date)}',
                style: TextStyle(color: context.muted),
              ),
            ]),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => showEditProfileDialog(context, ref),
          ),
        ]),
      ),
      if (s.experience.isNotEmpty || s.goals.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (s.experience.isNotEmpty) Text('Experience: ${s.experience}'),
              if (s.goals.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text('Goals: ${s.goals}')),
            ]),
          ),
        ),
    ]);
  }
}
