import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../domain/entities/habit_entity.dart';
import '../providers/habit_providers.dart';
import '_habit_form_fields.dart';

/// A page that pre-populates the habit form with an existing [HabitEntity] and
/// persists changes through [HabitController.updateHabit].
class EditHabitPage extends ConsumerStatefulWidget {
  /// Creates the edit-habit page for [habit].
  const EditHabitPage({super.key, required this.habit});

  /// The habit being edited.
  final HabitEntity habit;

  @override
  ConsumerState<EditHabitPage> createState() => _EditHabitPageState();
}

class _EditHabitPageState extends ConsumerState<EditHabitPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  late HabitFrequency _frequency;
  late Set<int> _targetDays;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final h = widget.habit;
    _titleController = TextEditingController(text: h.title);
    _descriptionController = TextEditingController(text: h.description);
    _frequency = h.frequency;
    _targetDays = Set<int>.from(h.targetDays);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final uid = ref.read(authControllerProvider).user?.id;
    if (uid == null) return;

    setState(() => _isSaving = true);

    final updated = HabitEntity(
      id: widget.habit.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      frequency: _frequency,
      targetDays: _frequency == HabitFrequency.weekly
          ? _targetDays.toList()
          : const [],
      currentStreak: widget.habit.currentStreak,
      longestStreak: widget.habit.longestStreak,
      completedDates: widget.habit.completedDates,
      color: widget.habit.color,
      iconName: widget.habit.iconName,
      createdAt: widget.habit.createdAt,
      updatedAt: DateTime.now(),
    );

    try {
      await ref
          .read(habitControllerProvider.notifier)
          .updateHabit(uid, updated);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Habit'),
        actions: <Widget>[
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontal = constraints.maxWidth >= 600 ? 40.0 : 24.0;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontal,
                    vertical: 24,
                  ),
                  child: Form(
                    key: _formKey,
                    child: HabitFormFields(
                      titleController: _titleController,
                      descriptionController: _descriptionController,
                      frequency: _frequency,
                      targetDays: _targetDays,
                      isSaving: _isSaving,
                      onFrequencyChanged: (f) =>
                          setState(() => _frequency = f),
                      onTargetDaysChanged: (days) =>
                          setState(() {
                            _targetDays
                              ..clear()
                              ..addAll(days);
                          }),
                    ),
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
