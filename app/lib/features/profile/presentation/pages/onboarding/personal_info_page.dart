import 'package:flutter/material.dart';

import 'schedule_page.dart';
import 'widgets/onboarding_scaffold.dart';
import 'widgets/primary_continue_button.dart';

/// Collects the user's display and local time details.
class PersonalInfoPage extends StatefulWidget {
  /// Creates the personal information page.
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _countryController = TextEditingController();
  final _timeZoneController = TextEditingController();

  @override
  void dispose() {
    _displayNameController.dispose();
    _countryController.dispose();
    _timeZoneController.dispose();
    super.dispose();
  }

  void _continue() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => SchedulePage(
        displayName: _displayNameController.text.trim(),
        country: _countryController.text.trim(),
        timeZone: _timeZoneController.text.trim(),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: 'Tell us about you',
      description: 'We use your local time to keep your study plan practical.',
      currentStep: 1,
      onBack: () => Navigator.of(context).pop(),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: _displayNameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Display name',
              ),
              validator: _required('Display name'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _countryController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Country',
              ),
              validator: _required('Country'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _timeZoneController,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _continue(),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Time zone',
                hintText: 'Asia/Kolkata',
              ),
              validator: (value) {
                final required = _required('Time zone')(value);
                if (required != null) return required;
                return value!.trim().contains('/')
                    ? null
                    : 'Use an IANA time zone, for example Asia/Kolkata.';
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

String? Function(String?) _required(String fieldName) {
  return (value) => value == null || value.trim().isEmpty
      ? '$fieldName is required.'
      : null;
}
