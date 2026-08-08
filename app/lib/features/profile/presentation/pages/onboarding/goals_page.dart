import 'package:flutter/material.dart';

import 'completion_page.dart';
import 'widgets/onboarding_scaffold.dart';
import 'widgets/primary_continue_button.dart';

/// Collects the user's daily study target.
class GoalsPage extends StatefulWidget {
  /// Creates the goals page with values gathered in earlier steps.
  const GoalsPage({
    required this.displayName,
    required this.country,
    required this.timeZone,
    required this.wakeUpTime,
    required this.sleepTime,
    required this.preferredStudyStart,
    required this.preferredStudyEnd,
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

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final _formKey = GlobalKey<FormState>();
  final _goalController = TextEditingController();

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  void _continue() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => CompletionPage(
        displayName: widget.displayName,
        country: widget.country,
        timeZone: widget.timeZone,
        wakeUpTime: widget.wakeUpTime,
        sleepTime: widget.sleepTime,
        preferredStudyStart: widget.preferredStudyStart,
        preferredStudyEnd: widget.preferredStudyEnd,
        dailyStudyGoalMinutes: int.parse(_goalController.text.trim()),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: 'Set a daily focus goal',
      description: 'Start with a realistic number of focused study minutes.',
      currentStep: 3,
      onBack: () => Navigator.of(context).pop(),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: _goalController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _continue(),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Daily focus goal',
                suffixText: 'minutes',
              ),
              validator: (value) {
                final goal = int.tryParse(value?.trim() ?? '');
                if (goal == null || goal <= 0) {
                  return 'Enter a whole number greater than zero.';
                }
                if (goal > 1440) return 'Enter 1,440 minutes or fewer.';
                return null;
              },
            ),
            const SizedBox(height: 24),
            PrimaryContinueButton(label: 'Continue', onPressed: _continue),
          ],
        ),
      ),
    );
  }
}
