import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/presentation/providers/auth_providers.dart';
import '../../features/authentication/presentation/states/auth_state.dart';
import '../../features/profile/presentation/providers/profile_providers.dart';
import '../../features/profile/presentation/states/profile_state.dart';

import 'app_routes.dart';
import 'route_names.dart';

/// Provides the application's centralized [GoRouter] configuration.
abstract final class AppRouter {
  /// Creates the application router and keeps it synchronized with app state.
  ///
  /// Authentication redirects are intentionally defined here so that screens
  /// never need to navigate in response to authentication state changes.
  static GoRouter create(Ref ref) {
    final refreshNotifier = _AppStateRefreshNotifier(ref);
    ref.onDispose(refreshNotifier.dispose);

    return GoRouter(
      routes: AppRoutes.routes,
      refreshListenable: refreshNotifier,
      redirect: (context, state) => _redirect(ref, state),
    );
  }

  /// Resolves the destination for the current authentication and profile state.
  ///
  /// Splash remains visible while authentication or profile bootstrapping is in
  /// progress. Returning `null` at the destination prevents redirect loops.
  static String? _redirect(Ref ref, GoRouterState state) {
    final authState = ref.read(authControllerProvider);
    final profileState = ref.read(profileControllerProvider);
    final location = state.matchedLocation;

    final target = _computeTarget(authState, profileState);
    // Return null when we are already at the computed target — prevents
    // GoRouter from pushing the same route and triggering a new frame.
    if (target == location) return null;
    return target;
  }

  /// Computes the canonical target route for the given [authState] and
  /// [profileState].
  ///
  /// This pure function is reused by both [_redirect] and
  /// [_AppStateRefreshNotifier] so that both always agree on what the
  /// target route is.
  static String _computeTarget(AuthState authState, ProfileState profileState) {
    if (authState.isLoading) return RouteNames.splash;

    if (authState.user != null) {
      if (profileState.isLoading) return RouteNames.splash;

      final profile = profileState.profile;
      if (profile == null || !profile.onboardingCompleted) {
        return RouteNames.onboarding;
      }

      return RouteNames.home;
    }

    return RouteNames.login;
  }
}

/// Exposes one router instance for the lifetime of the enclosing provider
/// scope, allowing GoRouter to react to authentication and profile updates.
final appRouterProvider = Provider<GoRouter>((ref) {
  final router = AppRouter.create(ref);
  ref.onDispose(router.dispose);
  return router;
});

/// Notifies GoRouter when the destination route changes.
///
/// ## Problem this solves
///
/// The naive approach — calling [notifyListeners] on every Riverpod state
/// change — causes a redirect storm:
///
/// 1. Auth/profile state changes → [notifyListeners] → GoRouter calls
///    `redirect` → GoRouter pushes the (same) route → GoRouter calls
///    [RouterDelegate.notifyListeners] → Flutter schedules a new frame →
///    [addPostFrameCallback] fires → repeat.
///
/// ## Solution
///
/// This notifier computes the *target route* from auth+profile state on every
/// change. It only calls [notifyListeners] when the target route itself
/// changes. Because GoRouter is told to navigate to a *different* route at
/// most once per real state transition, the feedback loop cannot form.
class _AppStateRefreshNotifier extends ChangeNotifier {
  _AppStateRefreshNotifier(Ref ref) {
    // Capture initial target so the first meaningful change is detected.
    _lastTarget = AppRouter._computeTarget(
      ref.read(authControllerProvider),
      ref.read(profileControllerProvider),
    );

    ref.listen<AuthState>(
      authControllerProvider,
      (previous, next) {
        final user = next.user;

        if (user != null && user.id != _profileUserId) {
          _profileUserId = user.id;
          ref.read(profileControllerProvider.notifier).loadProfile(user.id);
        } else if (!next.isLoading && user == null && _profileUserId != null) {
          _profileUserId = null;
          ref.read(profileControllerProvider.notifier).clearProfile();
        }

        _maybeNotify(ref);
      },
    );

    ref.listen<ProfileState>(
      profileControllerProvider,
      (previous, next) => _maybeNotify(ref),
    );
  }

  String? _profileUserId;

  /// The last target route that was surfaced to GoRouter.
  ///
  /// GoRouter is only notified when [_computeTarget] returns a route that
  /// differs from [_lastTarget], capping GoRouter at one redirect per real
  /// destination change regardless of how many intermediate states fire.
  late String _lastTarget;

  /// Notifies GoRouter only when the canonical target route has changed.
  void _maybeNotify(Ref ref) {
    final newTarget = AppRouter._computeTarget(
      ref.read(authControllerProvider),
      ref.read(profileControllerProvider),
    );

    if (newTarget == _lastTarget) return; // No destination change — skip.

    _lastTarget = newTarget;
    notifyListeners();
  }
}
