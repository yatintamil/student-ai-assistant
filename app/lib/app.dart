import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/router/app_router.dart';
import 'config/theme/app_theme.dart';

/// Root widget of the application.
///
/// Session restoration is handled entirely inside [AuthController.build], so
/// this widget only needs to configure routing and theming.
class StudentAIAssistantApp extends ConsumerWidget {
  /// Creates the application root.
  const StudentAIAssistantApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
