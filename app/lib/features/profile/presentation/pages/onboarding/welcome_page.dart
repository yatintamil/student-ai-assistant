import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'personal_info_page.dart';
import 'widgets/onboarding_scaffold.dart';
import 'widgets/primary_continue_button.dart';

/// Introduces the profile onboarding flow.
class WelcomePage extends StatelessWidget {
  /// Creates the welcome page.
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return OnboardingScaffold(
      title: 'Welcome to your study space',
      description: 'A few details help us shape a schedule that works for you.',
      currentStep: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(
                Icons.auto_awesome_outlined,
                size: 52,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 48),
          PrimaryContinueButton(
            label: 'Get started',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PersonalInfoPage(),
              ),
            ),
          ),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Maybe later'),
          ),
        ],
      ),
    );
  }
}
