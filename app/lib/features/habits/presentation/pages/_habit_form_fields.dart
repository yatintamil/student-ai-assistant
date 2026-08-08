import 'package:flutter/material.dart';

import '../../domain/entities/habit_entity.dart';

/// Shared form fields widget used by both [AddHabitPage] and [EditHabitPage].
///
/// Renders every editable field for a habit: title, description, frequency,
/// and — when [frequency] is [HabitFrequency.weekly] — a day-of-week picker.
/// Validation is declared here so both pages share identical rules.
class HabitFormFields extends StatelessWidget {
  /// Creates a [HabitFormFields] widget.
  const HabitFormFields({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.frequency,
    required this.targetDays,
    required this.isSaving,
    required this.onFrequencyChanged,
    required this.onTargetDaysChanged,
  });

  /// Controls the title text field.
  final TextEditingController titleController;

  /// Controls the description text field.
  final TextEditingController descriptionController;

  /// The currently selected frequency.
  final HabitFrequency frequency;

  /// The currently selected weekday numbers (ISO: 1 = Mon … 7 = Sun).
  /// Relevant only when [frequency] is [HabitFrequency.weekly].
  final Set<int> targetDays;

  /// When `true` all fields are disabled and the save spinner is shown.
  final bool isSaving;

  /// Called when the user selects a different [HabitFrequency].
  final ValueChanged<HabitFrequency> onFrequencyChanged;

  /// Called with the full updated set of selected weekday numbers.
  final ValueChanged<Set<int>> onTargetDaysChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // ── Title ──────────────────────────────────────────────────────────
        TextFormField(
          controller: titleController,
          enabled: !isSaving,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Title *',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Title is required.';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // ── Description ────────────────────────────────────────────────────
        TextFormField(
          controller: descriptionController,
          enabled: !isSaving,
          textInputAction: TextInputAction.next,
          maxLines: 3,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Description',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 16),

        // ── Frequency ──────────────────────────────────────────────────────
        DropdownButtonFormField<HabitFrequency>(
          initialValue: frequency,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Frequency',
          ),
          items: HabitFrequency.values
              .map(
                (f) => DropdownMenuItem(
                  value: f,
                  child: Text(_frequencyLabel(f)),
                ),
              )
              .toList(),
          onChanged: isSaving
              ? null
              : (value) {
                  if (value != null) onFrequencyChanged(value);
                },
        ),
        const SizedBox(height: 16),

        // ── Weekly day picker (visible only for weekly habits) ─────────────
        if (frequency == HabitFrequency.weekly) ...[
          _DayPicker(
            selectedDays: targetDays,
            enabled: !isSaving,
            onChanged: onTargetDaysChanged,
          ),
          const SizedBox(height: 16),
        ],

        const SizedBox(height: 16),
      ],
    );
  }

  static String _frequencyLabel(HabitFrequency f) => switch (f) {
        HabitFrequency.daily => 'Daily',
        HabitFrequency.weekly => 'Weekly (choose days)',
      };
}

// ---------------------------------------------------------------------------
// Private day-of-week picker
// ---------------------------------------------------------------------------

class _DayPicker extends StatelessWidget {
  const _DayPicker({
    required this.selectedDays,
    required this.enabled,
    required this.onChanged,
  });

  final Set<int> selectedDays;
  final bool enabled;
  final ValueChanged<Set<int>> onChanged;

  static const List<(int, String)> _days = [
    (1, 'Mo'),
    (2, 'Tu'),
    (3, 'We'),
    (4, 'Th'),
    (5, 'Fr'),
    (6, 'Sa'),
    (7, 'Su'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Repeat on',
          style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _days.map(((int, String) day) {
            final (number, label) = day;
            final isSelected = selectedDays.contains(number);

            return GestureDetector(
              onTap: enabled
                  ? () {
                      final updated = Set<int>.from(selectedDays);
                      if (isSelected) {
                        updated.remove(number);
                      } else {
                        updated.add(number);
                      }
                      onChanged(updated);
                    }
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? cs.primaryContainer
                      : cs.surfaceContainerHighest,
                ),
                child: Text(
                  label,
                  style: tt.labelMedium?.copyWith(
                    color: isSelected
                        ? cs.onPrimaryContainer
                        : cs.onSurfaceVariant,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
