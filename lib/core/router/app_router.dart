import 'package:go_router/go_router.dart';
import 'route_names.dart';
import 'route_guards.dart';
import '../../features/home/home_page.dart';
import '../../features/settings/settings_page.dart';

final appRouter = GoRouter(
  initialLocation: RouteNames.home,
  debugLogDiagnostics: true,
  redirect: authGuard,
  routes: [
    GoRoute(
      path: RouteNames.home,
      name: 'home',
      builder: (context, state) => HomePage.routePage(),
    ),
    GoRoute(
      path: RouteNames.settings,
      name: 'settings',
      builder: (context, state) => SettingsPage.routePage(),
    ),
  ],
);