import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/router/app_router.dart';
import 'config/theme/app_theme.dart';
import 'features/authentication/presentation/providers/auth_providers.dart';

/// Configures the application and starts the one-time session restoration.
class StudentAIAssistantApp extends ConsumerStatefulWidget {
  /// Creates the application root.
  const StudentAIAssistantApp({super.key});

  @override
  ConsumerState<StudentAIAssistantApp> createState() =>
      _StudentAIAssistantAppState();
}

/// Starts session restoration before the router evaluates its initial route.
class _StudentAIAssistantAppState
    extends ConsumerState<StudentAIAssistantApp> {
  @override
  void initState() {
    super.initState();
    ref.read(authControllerProvider.notifier).loadCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Student AI Assistant',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      routerConfig: router,
    );
  }
}
