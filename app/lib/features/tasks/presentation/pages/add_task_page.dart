import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../goals/presentation/providers/goal_providers.dart';
import '../../domain/entities/task_entity.dart';
import '../providers/task_providers.dart';

/// A page that collects all required fields for a new [TaskEntity] and
/// persists it through [TaskController.addTask].
class AddTaskPage extends ConsumerStatefulWidget {
  /// Creates the add-task page.
  const AddTaskPage({super.key});

  @override
  ConsumerState<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends ConsumerState<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _estimatedMinutesController = TextEditingController();
  final _categoryController = TextEditingController();

  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  TaskPriority _priority = TaskPriority.medium;
  String? _selectedGoalId;

  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _estimatedMinutesController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final uid = ref.read(authControllerProvider).user?.id;
    if (uid == null) return;

    setState(() => _isSaving = true);

    final now = DateTime.now();
    final task = TaskEntity(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: _dueDate,
      estimatedMinutes: int.parse(_estimatedMinutesController.text.trim()),
      priority: _priority,
      status: TaskStatus.pending,
      category: _categoryController.text.trim(),
      goalId: _selectedGoalId,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await ref.read(taskControllerProvider.notifier).addTask(uid, task);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
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
                    child: _TaskFormFields(
                      titleController: _titleController,
                      descriptionController: _descriptionController,
                      estimatedMinutesController: _estimatedMinutesController,
                      categoryController: _categoryController,
                      dueDate: _dueDate,
                      priority: _priority,
                      isSaving: _isSaving,
                      onPickDueDate: _pickDueDate,
                      onPriorityChanged: (p) => setState(() => _priority = p),
                      selectedGoalId: _selectedGoalId,
                      onGoalChanged: (gId) => setState(() => _selectedGoalId = gId),
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

// ---------------------------------------------------------------------------
// Shared form fields widget
// ---------------------------------------------------------------------------

/// Renders all editable fields for a task form.
class _TaskFormFields extends ConsumerWidget {
  const _TaskFormFields({
    required this.titleController,
    required this.descriptionController,
    required this.estimatedMinutesController,
    required this.categoryController,
    required this.dueDate,
    required this.priority,
    required this.isSaving,
    required this.onPickDueDate,
    required this.onPriorityChanged,
    required this.selectedGoalId,
    required this.onGoalChanged,
  });

  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController estimatedMinutesController;
  final TextEditingController categoryController;
  final DateTime dueDate;
  final TaskPriority priority;
  final bool isSaving;
  final VoidCallback onPickDueDate;
  final ValueChanged<TaskPriority> onPriorityChanged;
  final String? selectedGoalId;
  final ValueChanged<String?> onGoalChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalControllerProvider).goals;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Title
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

        // Description
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

        // Linked Goal Dropdown
        DropdownButtonFormField<String?>(
          value: selectedGoalId,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Link to Goal (Optional)',
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('None (General Task)'),
            ),
            ...goals.map((goal) => DropdownMenuItem<String?>(
                  value: goal.id,
                  child: Text('[${goal.level.name.toUpperCase()}] ${goal.title}'),
                )),
          ],
          onChanged: isSaving ? null : onGoalChanged,
        ),
        const SizedBox(height: 16),

        // Due date
        InkWell(
          onTap: isSaving ? null : onPickDueDate,
          borderRadius: BorderRadius.circular(4),
          child: InputDecorator(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Due date',
              suffixIcon: Icon(Icons.calendar_today_outlined),
            ),
            child: Text(DateFormat.yMMMd().format(dueDate)),
          ),
        ),
        const SizedBox(height: 16),

        // Estimated minutes
        TextFormField(
          controller: estimatedMinutesController,
          enabled: !isSaving,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Estimated minutes *',
            suffixText: 'min',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Estimated minutes is required.';
            }
            final parsed = int.tryParse(value.trim());
            if (parsed == null || parsed <= 0) {
              return 'Must be greater than 0.';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Priority
        DropdownButtonFormField<TaskPriority>(
          initialValue: priority,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Priority',
          ),
          items: TaskPriority.values
              .map(
                (p) => DropdownMenuItem(
                  value: p,
                  child: Text(_priorityLabel(p)),
                ),
              )
              .toList(),
          onChanged: isSaving
              ? null
              : (value) {
                  if (value != null) onPriorityChanged(value);
                },
        ),
        const SizedBox(height: 16),

        // Category
        TextFormField(
          controller: categoryController,
          enabled: !isSaving,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Category',
            hintText: 'e.g. Math, Science',
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  String _priorityLabel(TaskPriority priority) {
    return switch (priority) {
      TaskPriority.low => 'Low',
      TaskPriority.medium => 'Medium',
      TaskPriority.high => 'High',
    };
  }
}
