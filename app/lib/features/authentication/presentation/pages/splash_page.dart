import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';

/// Displays the application startup screen while session restoration runs.
///
/// GoRouter owns authentication redirects; this page only renders the loading
/// state and never initiates navigation or authentication operations.
class SplashPage extends ConsumerWidget {
  /// Creates the splash page.
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isLoading = authState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth >= 600 ? 40.0 : 24.0;

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: colorScheme.primaryContainer,
                        child: Icon(
                          Icons.school_outlined,
                          color: colorScheme.onPrimaryContainer,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Student AI Assistant',
                        style: textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: isLoading ? null : colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
