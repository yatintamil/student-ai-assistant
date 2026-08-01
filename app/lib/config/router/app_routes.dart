import 'package:go_router/go_router.dart';

import '../../features/splash/presentation/pages/splash_page.dart';
import 'route_names.dart';

abstract final class AppRoutes {
  static final List<RouteBase> routes = [
    GoRoute(
      path: RouteNames.splash,
      builder: (context, state) => const SplashPage(),
    ),
  ];
}