import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../domain/entities/goal_entity.dart';
import '../providers/goal_providers.dart';

/// Detailed view of a single goal showing:
/// - Progress slider and percentage
/// - Linked tasks (completed and pending)
/// - Child goals (sub-goals)
/// - Target date
/// - Edit and delete actions
class GoalDetailPage extends ConsumerStatefulWidget {
  const GoalDetailPage({super.key, required this.goal});

  final GoalEntity goal;

  @override
  ConsumerState<GoalDetailPage> createState() => _GoalDetailPageState();
}

class _GoalDetailPageState extends ConsumerState<GoalDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = ref.read(authControllerProvider).user?.id;
      if (uid != null) {
        ref.read(taskControllerProvider.notifier).loadTasks(uid);
        ref.read(goalControllerProvider.notifier).loadGoals(uid);
      }
    });
  }

  Future<void> _updateProgress(double newProgress) async {
    final uid = ref.read(authControllerProvider).user?.id;
    if (uid == null) return;

    final updated = widget.goal.copyWith(
      progress: newProgress,
      isCompleted: newProgress >= 1.0,
      updatedAt: DateTime.now(),
    );

    await ref.read(goalControllerProvider.notifier).updateGoal(uid, updated);
  }

  Future<void> _editGoal() async {
    // Navigate back and trigger edit dialog
    if (mounted) {
      Navigator.pop(context, {'action': 'edit', 'goal': widget.goal});
    }
  }

  Future<void> _deleteGoal() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal?'),
        content: Text('Are you sure you want to delete "${widget.goal.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final uid = ref.read(authControllerProvider).user?.id;
      if (uid != null) {
        await ref.read(goalControllerProvider.notifier).deleteGoal(uid, widget.goal.id);
        if (mounted) Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tasks = ref.watch(taskControllerProvider).tasks;
    final allGoals = ref.watch(goalControllerProvider).goals;

    // Find linked tasks
    final linkedTasks = tasks.where((t) => t.goalId == widget.goal.id).toList();
    final completedTasks = linkedTasks.where((t) => t.status == TaskStatus.completed).toList();
    final pendingTasks = linkedTasks.where((t) => t.status == TaskStatus.pending).toList();

    // Find child goals
    final childGoals = allGoals.where((g) => g.parentGoalId == widget.goal.id).toList();
    childGoals.sort((a, b) => a.level.index.compareTo(b.level.index));

    // Find parent goal
    final parentGoal = widget.goal.parentGoalId != null
        ? allGoals.firstWhere(
            (g) => g.id == widget.goal.parentGoalId,
            orElse: () => widget.goal,
          )
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.goal.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _editGoal,
            tooltip: 'Edit Goal',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteGoal,
            tooltip: 'Delete Goal',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Goal header card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Icon(
                            _getCategoryIcon(widget.goal.category),
                            size: 24,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.goal.title,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 8,
                                children: [
                                  Chip(
                                    label: Text(
                                      widget.goal.level.name.toUpperCase(),
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  Chip(
                                    label: Text(
                                      widget.goal.category.name.toUpperCase(),
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (widget.goal.description.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        widget.goal.description,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                    if (widget.goal.targetDate != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Target: ${DateFormat.yMMMd().format(widget.goal.targetDate!)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (parentGoal != null && parentGoal.id != widget.goal.id) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.account_tree_outlined,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Part of: ${parentGoal.title}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Progress section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${(widget.goal.progress * 100).toInt()}%',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Slider(
                      value: widget.goal.progress,
                      min: 0.0,
                      max: 1.0,
                      divisions: 20,
                      label: '${(widget.goal.progress * 100).toInt()}%',
                      onChanged: _updateProgress,
                    ),
                    if (linkedTasks.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${completedTasks.length} of ${linkedTasks.length} linked tasks completed',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Linked tasks section
            if (linkedTasks.isNotEmpty) ...[
              Text(
                'Linked Tasks (${linkedTasks.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    if (pendingTasks.isNotEmpty) ...[
                      _TaskSection(
                        title: 'Pending',
                        tasks: pendingTasks,
                        icon: Icons.pending_actions_outlined,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                    if (completedTasks.isNotEmpty) ...[
                      if (pendingTasks.isNotEmpty) const Divider(height: 1),
                      _TaskSection(
                        title: 'Completed',
                        tasks: completedTasks,
                        icon: Icons.check_circle_outline,
                        color: Colors.green,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Child goals section
            if (childGoals.isNotEmpty) ...[
              Text(
                'Sub-Goals (${childGoals.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...childGoals.map(
                (child) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      child: Icon(
                        _getCategoryIcon(child.category),
                        size: 18,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                    title: Text(
                      child.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Chip(
                              label: Text(
                                child.level.name.toUpperCase(),
                                style: const TextStyle(fontSize: 9),
                              ),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: child.progress,
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${(child.progress * 100).toInt()}%',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Icon(
                      child.isCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: child.isCompleted
                          ? Colors.green
                          : theme.colorScheme.outline,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GoalDetailPage(goal: child),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Empty states
            if (linkedTasks.isEmpty && childGoals.isEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No linked tasks or sub-goals yet',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create tasks and link them to this goal, or add sub-goals to break this down further.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(GoalCategory category) {
    switch (category) {
      case GoalCategory.career:
        return Icons.work_outline;
      case GoalCategory.education:
        return Icons.school_outlined;
      case GoalCategory.health:
        return Icons.favorite_outline;
      case GoalCategory.personal:
        return Icons.person_outline;
      case GoalCategory.finance:
        return Icons.attach_money_outlined;
      case GoalCategory.business:
        return Icons.business_outlined;
      case GoalCategory.projects:
        return Icons.folder_outlined;
      case GoalCategory.other:
        return Icons.flag_outlined;
    }
  }
}

class _TaskSection extends StatelessWidget {
  const _TaskSection({
    required this.title,
    required this.tasks,
    required this.icon,
    required this.color,
  });

  final String title;
  final List<TaskEntity> tasks;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                '$title (${tasks.length})',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...tasks.map(
            (task) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    task.status == TaskStatus.completed
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    size: 16,
                    color: task.status == TaskStatus.completed
                        ? Colors.green
                        : theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            decoration: task.status == TaskStatus.completed
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        Text(
                          '${task.estimatedMinutes} min · ${DateFormat.MMMd().format(task.dueDate)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
