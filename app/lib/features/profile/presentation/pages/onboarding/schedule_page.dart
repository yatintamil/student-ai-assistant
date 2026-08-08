import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'goals_page.dart';
import 'widgets/onboarding_scaffold.dart';
import 'widgets/primary_continue_button.dart';

/// Collects the user's preferred daily schedule.
class SchedulePage extends StatefulWidget {
  /// Creates the schedule page with values gathered in the preceding step.
  const SchedulePage({
    required this.displayName,
    required this.country,
    required this.timeZone,
    super.key,
  });

  /// The selected display name.
  final String displayName;

  /// The selected country.
  final String country;

  /// The selected IANA time-zone identifier.
  final String timeZone;

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  TimeOfDay? _wakeUpTime;
  TimeOfDay? _sleepTime;
  TimeOfDay? _workStartTime;
  TimeOfDay? _workEndTime;

  Future<void> _selectTime(void Function(TimeOfDay) onSelected) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (selected != null && mounted) setState(() => onSelected(selected));
  }

  void _continue() {
    if (<TimeOfDay?>[_wakeUpTime, _sleepTime, _workStartTime, _workEndTime]
        .any((time) => time == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose all four times.')),
      );
      return;
    }
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => GoalsPage(
        displayName: widget.displayName,
        country: widget.country,
        timeZone: widget.timeZone,
        wakeUpTime: _format(_wakeUpTime!),
        sleepTime: _format(_sleepTime!),
        preferredStudyStart: _format(_workStartTime!),
        preferredStudyEnd: _format(_workEndTime!),
      ),
    ));
  }

  String _format(TimeOfDay time) => DateFormat('HH:mm').format(
        DateTime(2000, 1, 1, time.hour, time.minute),
      );

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: 'Plan your day',
      description: 'Choose the times that best reflect your usual routine.',
      currentStep: 2,
      onBack: () => Navigator.of(context).pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _TimeField(label: 'Wake up time', value: _wakeUpTime, onTap: () => _selectTime((value) => _wakeUpTime = value)),
          const SizedBox(height: 16),
          _TimeField(label: 'Sleep time', value: _sleepTime, onTap: () => _selectTime((value) => _sleepTime = value)),
          const SizedBox(height: 16),
          _TimeField(label: 'Preferred work start', value: _workStartTime, onTap: () => _selectTime((value) => _workStartTime = value)),
          const SizedBox(height: 16),
          _TimeField(label: 'Preferred work end', value: _workEndTime, onTap: () => _selectTime((value) => _workEndTime = value)),
          const SizedBox(height: 24),
          PrimaryContinueButton(label: 'Continue', onPressed: _continue),
        ],
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({required this.label, required this.value, required this.onTap});
  final String label;
  final TimeOfDay? value;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.schedule_outlined),
        label: Align(
          alignment: Alignment.centerLeft,
          child: Text(value == null ? label : '$label: ${value!.format(context)}'),
        ),
      );
}
