import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/dashboard_page.dart';
import '../../features/profile/profile_page.dart';
import '../../features/programs/program_detail_page.dart';
import '../../features/programs/programs_page.dart';
import '../../features/shell/shell.dart';
import '../../features/shell/widgets/content_width.dart';
import '../../features/statistics/records_page.dart';
import '../../features/statistics/statistics_page.dart';
import '../../features/training/training_page.dart';
import '../../features/training/workout_page.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(path: '/', builder: (c, s) => const DashboardPage()),
          GoRoute(path: '/training', builder: (c, s) => const TrainingPage()),
          GoRoute(path: '/programs', builder: (c, s) => const ProgramsPage()),
          GoRoute(path: '/stats', builder: (c, s) => const StatisticsPage()),
          GoRoute(path: '/profile', builder: (c, s) => const ProfilePage()),
        ],
      ),
      GoRoute(path: '/workout', builder: (c, s) => const ContentWidth(child: WorkoutPage())),
      GoRoute(
          path: '/program/:id',
          builder: (c, s) => ContentWidth(child: ProgramDetailPage(programId: s.pathParameters['id']!))),
      GoRoute(path: '/records', builder: (c, s) => const ContentWidth(child: RecordsPage())),
    ],
  );
}
