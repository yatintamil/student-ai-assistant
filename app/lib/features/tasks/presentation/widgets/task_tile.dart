import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/task_entity.dart';
import 'priority_chip.dart';

/// A list tile that represents a single [TaskEntity].
///
/// Provides a checkbox to toggle completion, and exposes [onTap] for
/// navigation to the edit page. Swipe-to-dismiss is handled by the parent
/// list via [Dismissible]; this widget is the dismissible child.
class TaskTile extends StatelessWidget {
  /// Creates a [TaskTile] for [task].
  const TaskTile({
    super.key,
    required this.task,
    required this.onToggleCompleted,
    this.onTap,
  });

  /// The task to display.
  final TaskEntity task;

  /// Called when the checkbox value changes.
  final VoidCallback onToggleCompleted;

  /// Called when the tile body is tapped (typically opens edit page).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isCompleted = task.status == TaskStatus.completed;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Checkbox(
        value: isCompleted,
        onChanged: (_) => onToggleCompleted(),
      ),
      title: Text(
        task.title,
        style: textTheme.bodyLarge?.copyWith(
          decoration:
              isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
          color:
              isCompleted ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: <Widget>[
          Icon(
            Icons.calendar_today_outlined,
            size: 12,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 3),
          Text(
            DateFormat.MMMd().format(task.dueDate),
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 10),
          PriorityChip(priority: task.priority),
        ],
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}
