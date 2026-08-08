import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../authentication/presentation/providers/auth_providers.dart';
import '../../../domain/entities/profile_entity.dart';
import '../../providers/profile_providers.dart';
import 'widgets/onboarding_scaffold.dart';
import 'widgets/primary_continue_button.dart';

/// Confirms the user's choices and saves the completed profile.
class CompletionPage extends ConsumerStatefulWidget {
  /// Creates the completion page with the user's onboarding choices.
  const CompletionPage({
    required this.displayName,
    required this.country,
    required this.timeZone,
    required this.wakeUpTime,
    required this.sleepTime,
    required this.preferredStudyStart,
    required this.preferredStudyEnd,
    required this.dailyStudyGoalMinutes,
    super.key,
  });

  /// The selected display name.
  final String displayName;
  /// The selected country.
  final String country;
  /// The selected time zone.
  final String timeZone;
  /// The selected wake-up time.
  final String wakeUpTime;
  /// The selected sleep time.
  final String sleepTime;
  /// The selected study start time.
  final String preferredStudyStart;
  /// The selected study end time.
  final String preferredStudyEnd;
  /// The selected daily study target.
  final int dailyStudyGoalMinutes;

  @override
  ConsumerState<CompletionPage> createState() => _CompletionPageState();
}

class _CompletionPageState extends ConsumerState<CompletionPage> {
  Future<void> _saveProfile() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in before completing onboarding.')),
      );
      return;
    }

    final now = DateTime.now();
    final profile = ProfileEntity(
      id: user.id,
      displayName: widget.displayName,
      email: user.email,
      photoUrl: user.photoUrl,
      country: widget.country,
      timeZone: widget.timeZone,
      sleepTime: widget.sleepTime,
      wakeUpTime: widget.wakeUpTime,
      preferredStudyStart: widget.preferredStudyStart,
      preferredStudyEnd: widget.preferredStudyEnd,
      dailyStudyGoalMinutes: widget.dailyStudyGoalMinutes,
      onboardingCompleted: true,
      createdAt: now,
      updatedAt: now,
    );

    await ref.read(profileControllerProvider.notifier).saveProfile(profile);
    if (!mounted) return;
    final profileState = ref.read(profileControllerProvider);
    if (profileState.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(profileState.errorMessage!)),
      );
      return;
    }
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(profileControllerProvider).isLoading;
    final colorScheme = Theme.of(context).colorScheme;
    return OnboardingScaffold(
      title: 'You are all set',
      description: 'Your daily focus plan is ready. You can update it later.',
      currentStep: 4,
      onBack: isLoading ? null : () => Navigator.of(context).pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: colorScheme.secondaryContainer,
              child: Icon(
                Icons.check_circle_outline,
                size: 48,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 32),
          PrimaryContinueButton(
            label: 'Go to home',
            isLoading: isLoading,
            onPressed: _saveProfile,
          ),
        ],
      ),
    );
  }
}
