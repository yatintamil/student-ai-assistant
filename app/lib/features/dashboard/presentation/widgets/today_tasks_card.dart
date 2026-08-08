import 'package:flutter/material.dart';

import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/presentation/pages/edit_task_page.dart';
import '../../../tasks/presentation/pages/task_list_page.dart';
import '../../../tasks/presentation/widgets/priority_chip.dart';
import '../../../tasks/presentation/widgets/task_empty_state.dart';

/// Displays today's tasks sourced from real [TaskEntity] objects.
///
/// Each row shows a completion toggle, the task title, and its priority.
/// Tapping a row navigates to [EditTaskPage]. [onToggle] is called with the
/// [TaskEntity] when the user checks or unchecks it. The "See all" button
/// navigates to [TaskListPage].
class TodayTasksCard extends StatelessWidget {
  /// Creates a [TodayTasksCard].
  const TodayTasksCard({
    super.key,
    required this.tasks,
    required this.onToggle,
  });

  /// The tasks to render. May be empty — [TaskEmptyState] is shown in that
  /// case.
  final List<TaskEntity> tasks;

  /// Called with the [TaskEntity] whose completion state was toggled.
  final void Function(TaskEntity task) onToggle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Header row with "See all" navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.check_circle_outline,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Today's Tasks",
                        style: textTheme.titleSmall?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => _navigateToTaskList(context),
                  child: const Text('See all'),
                ),
              ],
            ),
            // Task list or empty state
            if (tasks.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: TaskEmptyState(),
              )
            else
              ...tasks.map(
                (task) => _TaskRow(
                  task: task,
                  onToggle: () => onToggle(task),
                  onTap: () => _navigateToEdit(context, task),
                  textTheme: textTheme,
                  colorScheme: colorScheme,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _navigateToTaskList(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const TaskListPage()),
    );
  }

  void _navigateToEdit(BuildContext context, TaskEntity task) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => EditTaskPage(task: task)),
    );
  }
}

// ---------------------------------------------------------------------------
// Private row widget
// ---------------------------------------------------------------------------

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.task,
    required this.onToggle,
    required this.onTap,
    required this.textTheme,
    required this.colorScheme,
  });

  final TaskEntity task;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == TaskStatus.completed;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: <Widget>[
            // Completion toggle — separate gesture so it doesn't trigger onTap
            GestureDetector(
              onTap: onToggle,
              child: Icon(
                isCompleted
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked,
                size: 22,
                color: isCompleted
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                task.title,
                style: textTheme.bodyMedium?.copyWith(
                  color: isCompleted
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onSurface,
                  decoration:
                      isCompleted ? TextDecoration.lineThrough : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            PriorityChip(priority: task.priority),
          ],
        ),
      ),
    );
  }
}
