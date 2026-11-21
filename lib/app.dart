import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/common.dart';
import 'features/shell/sync_driver.dart';
import 'providers/providers.dart';

class PowerliftingApp extends ConsumerWidget {
  const PowerliftingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(settingsProvider.select((s) => s.theme));
    final boot = ref.watch(bootstrapProvider);
    return MaterialApp.router(
      title: 'E',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: switch (theme) {
        'light' => ThemeMode.light,
        'system' => ThemeMode.system,
        _ => ThemeMode.dark,
      },
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) => boot.when(
        data: (_) => SyncDriver(child: child ?? const SizedBox.shrink()),
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, _) => Scaffold(
          body: EmptyState(
            icon: Icons.error_outline,
            title: 'Nem sikerült megnyitni az adatbázist',
            message: '$e',
            action: FilledButton(onPressed: () => ref.invalidate(bootstrapProvider), child: const Text('Újra')),
          ),
        ),
      ),
    );
  }
}
