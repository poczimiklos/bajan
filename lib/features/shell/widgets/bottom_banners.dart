import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/providers.dart';
import '../../training/widgets/rest_timer.dart';

/// Rest timer + "workout in progress" strip shown above the navigation.
class BottomBanners extends ConsumerWidget {
  const BottomBanners({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(workoutEditorProvider);
    return Column(mainAxisSize: MainAxisSize.min, children: [
      const RestTimerBar(),
      if (active != null && active.status == 'active')
        Material(
          color: context.accent,
          child: InkWell(
            onTap: () => context.push('/workout'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(children: [
                Icon(Icons.play_arrow_rounded, color: context.cs.onPrimary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Workout in progress · ${active.name}',
                      style: TextStyle(color: context.cs.onPrimary, fontWeight: FontWeight.w700)),
                ),
                Icon(Icons.chevron_right, color: context.cs.onPrimary),
              ]),
            ),
          ),
        ),
    ]);
  }
}
