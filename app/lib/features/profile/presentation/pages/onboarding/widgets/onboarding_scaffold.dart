import 'package:flutter/material.dart';

import 'onboarding_progress.dart';

/// Provides the responsive Material 3 layout shared by onboarding pages.
class OnboardingScaffold extends StatelessWidget {
  /// Creates the shared onboarding page layout.
  const OnboardingScaffold({
    required this.title,
    required this.description,
    required this.child,
    this.currentStep,
    this.totalSteps = 5,
    this.onBack,
    super.key,
  });

  /// Page heading.
  final String title;

  /// Supporting copy below [title].
  final String description;

  /// Page-specific content.
  final Widget child;

  /// The active zero-based flow step. Omits progress when null.
  final int? currentStep;

  /// Total count shown by the progress indicator.
  final int totalSteps;

  /// Optional action to return to the preceding page.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: onBack == null
          ? null
          : AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBack,
                tooltip: 'Back',
              ),
            ),
      body: SafeArea(
        top: onBack == null,
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
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      if (currentStep != null) ...<Widget>[
                        OnboardingProgress(
                          currentStep: currentStep!,
                          totalSteps: totalSteps,
                        ),
                        const SizedBox(height: 32),
                      ],
                      Text(title, style: textTheme.headlineMedium),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 32),
                      child,
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
