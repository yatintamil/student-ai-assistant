import 'package:go_router/go_router.dart';

import 'app_routes.dart';

/// Provides the application's centralized [GoRouter] configuration.
abstract final class AppRouter {
  /// The application router.
  ///
  /// TODO(auth guards): Add authentication-aware redirects here once the
  /// destination flow is ready. Redirect logic is intentionally not enabled.
  static final GoRouter router = GoRouter(
    routes: AppRoutes.routes,
  );
}
