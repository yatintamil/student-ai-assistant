import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../domain/entities/habit_entity.dart';
import '../providers/habit_providers.dart';
import '_habit_form_fields.dart';

/// A page that collects all required fields for a new [HabitEntity] and
/// persists it through [HabitController.addHabit].
class AddHabitPage extends ConsumerStatefulWidget {
  /// Creates the add-habit page.
  const AddHabitPage({super.key});

  @override
  ConsumerState<AddHabitPage> createState() => _AddHabitPageState();
}

class _AddHabitPageState extends ConsumerState<AddHabitPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  HabitFrequency _frequency = HabitFrequency.daily;
  final Set<int> _targetDays = {};
  bool _isSaving = false;

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

    final now = DateTime.now();
    final habit = HabitEntity(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      frequency: _frequency,
      targetDays: _frequency == HabitFrequency.weekly
          ? _targetDays.toList()
          : const [],
      currentStreak: 0,
      longestStreak: 0,
      completedDates: const [],
      color: '#2563EB',
      iconName: 'loop',
      createdAt: now,
      updatedAt: now,
    );

    try {
      await ref.read(habitControllerProvider.notifier).addHabit(uid, habit);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Habit'),
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
