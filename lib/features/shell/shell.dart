import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'widgets/bottom_banners.dart';
import 'widgets/content_width.dart';

const _tabs = [
  ('/', Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
  ('/training', Icons.fitness_center_outlined, Icons.fitness_center, 'Training'),
  ('/programs', Icons.event_note_outlined, Icons.event_note, 'Programs'),
  ('/stats', Icons.show_chart_outlined, Icons.show_chart, 'Statistics'),
  ('/profile', Icons.person_outline, Icons.person, 'Profile'),
];

class AppShell extends ConsumerWidget {
  final String location;
  final Widget child;
  const AppShell({super.key, required this.location, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = _tabs.indexWhere((t) => t.$1 == location).clamp(0, _tabs.length - 1);
    final wide = MediaQuery.sizeOf(context).width >= 800;

    const banner = BottomBanners();

    if (wide) {
      return Scaffold(
        body: Row(children: [
          SafeArea(
            child: NavigationRail(
              selectedIndex: index,
              labelType: NavigationRailLabelType.all,
              onDestinationSelected: (i) => context.go(_tabs[i].$1),
              destinations: [
                for (final t in _tabs)
                  NavigationRailDestination(icon: Icon(t.$2), selectedIcon: Icon(t.$3), label: Text(t.$4)),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Column(children: [
              Expanded(child: SafeArea(bottom: false, child: ContentWidth(maxWidth: 1000, child: child))),
              banner,
            ]),
          ),
        ]),
      );
    }

    return Scaffold(
      body: SafeArea(bottom: false, child: child),
      bottomNavigationBar: Column(mainAxisSize: MainAxisSize.min, children: [
        banner,
        NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) => context.go(_tabs[i].$1),
          destinations: [
            for (final t in _tabs) NavigationDestination(icon: Icon(t.$2), selectedIcon: Icon(t.$3), label: t.$4),
          ],
        ),
      ]),
    );
  }
}
