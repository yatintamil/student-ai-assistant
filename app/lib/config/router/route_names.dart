abstract final class RouteNames {
  const RouteNames._();

  /// The startup route that restores the current authentication session.
  static const String splash = '/';

  /// The sign-in route.
  static const String login = '/login';

  /// The account-registration route.
  static const String register = '/register';

  /// The password-reset route.
  static const String forgotPassword = '/forgot-password';

  /// The onboarding route.
  static const String onboarding = '/onboarding';

  /// The authenticated home route.
  static const String home = '/home';

  /// The application settings route.
  static const String settings = '/settings';
}
