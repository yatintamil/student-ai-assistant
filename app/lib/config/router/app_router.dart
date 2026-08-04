import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/presentation/providers/auth_providers.dart';
import '../../features/authentication/presentation/states/auth_state.dart';

import 'app_routes.dart';
import 'route_names.dart';

/// Provides the application's centralized [GoRouter] configuration.
abstract final class AppRouter {
  /// Creates the application router and keeps it synchronized with [AuthState].
  /// 
  /// Authentication redirects are intentionally defined here so that screens
  /// never need to navigate in response to authentication state changes.
  static GoRouter create(Ref ref) {
    final refreshNotifier = _AuthStateRefreshNotifier(ref);
    ref.onDispose(refreshNotifier.dispose);

    return GoRouter(
      routes: AppRoutes.routes,
      refreshListenable: refreshNotifier,
      redirect: (context, state) => _redirect(ref, state),
    );
  }

  /// Resolves the destination for the current [AuthState].
  ///
  /// While authentication is loading, the splash route remains visible. Once
  /// loading completes, authenticated users go to home and all other states,
  /// including failures, go to login. Returning `null` at the destination
  /// prevents redirect loops.
  static String? _redirect(Ref ref, GoRouterState state) {
    final authState = ref.read(authControllerProvider);
    final location = state.matchedLocation;

    if (authState.isLoading) {
      return location == RouteNames.splash ? null : RouteNames.splash;
    }

    if (authState.user != null) {
      return location == RouteNames.home ? null : RouteNames.home;
    }

    return location == RouteNames.login ? null : RouteNames.login;
  }
}

/// Exposes one router instance for the lifetime of the enclosing provider
/// scope, allowing GoRouter to react to [authControllerProvider] updates.
final appRouterProvider = Provider<GoRouter>((ref) {
  final router = AppRouter.create(ref);
  ref.onDispose(router.dispose);
  return router;
});

/// Notifies GoRouter whenever the authentication state changes.
class _AuthStateRefreshNotifier extends ChangeNotifier {
  /// Subscribes this notifier to the application's [AuthState].
  _AuthStateRefreshNotifier(Ref ref) {
    ref.listen<AuthState>(authControllerProvider, (_, _) => notifyListeners());
  }
}
