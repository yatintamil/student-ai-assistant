import 'package:flutter/material.dart';

/// Displays the user's position within the onboarding flow.
class OnboardingProgress extends StatelessWidget {
  /// Creates an onboarding progress indicator.
  const OnboardingProgress({
    required this.currentStep,
    required this.totalSteps,
    super.key,
  });

  /// The zero-based index of the active step.
  final int currentStep;

  /// The number of steps in the flow.
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final progress = totalSteps == 0 ? 0.0 : (currentStep + 1) / totalSteps;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: 'Step ${currentStep + 1} of $totalSteps',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Step ${currentStep + 1} of $totalSteps',
            style: textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: progress),
        ],
      ),
    );
  }
}
