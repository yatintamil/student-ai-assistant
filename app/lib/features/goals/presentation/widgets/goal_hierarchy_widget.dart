import 'package:flutter/material.dart';
import '../../domain/entities/goal_entity.dart';

/// Displays goals in a hierarchical tree structure based on parentGoalId.
/// 
/// Goals are organized by level (Vision → Long-term → Quarterly → Monthly → Weekly → Daily)
/// with visual indentation showing parent-child relationships.
class GoalHierarchyWidget extends StatelessWidget {
  const GoalHierarchyWidget({
    super.key,
    required this.goals,
    required this.onGoalTap,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleComplete,
  });

  final List<GoalEntity> goals;
  final void Function(GoalEntity) onGoalTap;
  final void Function(GoalEntity) onEdit;
  final void Function(GoalEntity) onDelete;
  final void Function(GoalEntity, bool) onToggleComplete;

  @override
  Widget build(BuildContext context) {
    // Build hierarchy: find root goals (no parent) and their descendants
    final rootGoals = goals.where((g) => g.parentGoalId == null).toList();
    
    // Sort by level order: vision → long-term → quarterly → monthly → weekly → daily
    rootGoals.sort((a, b) => a.level.index.compareTo(b.level.index));

    if (rootGoals.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No goals defined yet.'),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rootGoals.length,
      itemBuilder: (context, index) {
        return _GoalTreeNode(
          goal: rootGoals[index],
          allGoals: goals,
          level: 0,
          onGoalTap: onGoalTap,
          onEdit: onEdit,
          onDelete: onDelete,
          onToggleComplete: onToggleComplete,
        );
      },
    );
  }
}

class _GoalTreeNode extends StatefulWidget {
  const _GoalTreeNode({
    required this.goal,
    required this.allGoals,
    required this.level,
    required this.onGoalTap,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleComplete,
  });

  final GoalEntity goal;
  final List<GoalEntity> allGoals;
  final int level;
  final void Function(GoalEntity) onGoalTap;
  final void Function(GoalEntity) onEdit;
  final void Function(GoalEntity) onDelete;
  final void Function(GoalEntity, bool) onToggleComplete;

  @override
  State<_GoalTreeNode> createState() => _GoalTreeNodeState();
}

class _GoalTreeNodeState extends State<_GoalTreeNode> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final children = widget.allGoals
        .where((g) => g.parentGoalId == widget.goal.id)
        .toList()
      ..sort((a, b) => a.level.index.compareTo(b.level.index));

    final hasChildren = children.isNotEmpty;
    final indentPadding = widget.level * 24.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(left: indentPadding, bottom: 8),
          child: Card(
            elevation: widget.level == 0 ? 2 : 1,
            color: widget.level == 0
                ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                : null,
            child: InkWell(
              onTap: () => widget.onGoalTap(widget.goal),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Expand/collapse icon if has children
                    if (hasChildren)
                      IconButton(
                        icon: Icon(
                          _isExpanded
                              ? Icons.expand_more
                              : Icons.chevron_right,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          setState(() => _isExpanded = !_isExpanded);
                        },
                      )
                    else
                      const SizedBox(width: 20),
                    const SizedBox(width: 8),

                    // Goal icon by category
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        _getCategoryIcon(widget.goal.category),
                        size: 16,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Goal details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.goal.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              decoration: widget.goal.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Chip(
                                label: Text(
                                  widget.goal.level.name.toUpperCase(),
                                  style: const TextStyle(fontSize: 9),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                              const SizedBox(width: 8),
                              // Progress indicator
                              Container(
                                width: 60,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: widget.goal.progress,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${(widget.goal.progress * 100).toInt()}%',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Actions
                    Checkbox(
                      value: widget.goal.isCompleted,
                      onChanged: (val) {
                        if (val != null) {
                          widget.onToggleComplete(widget.goal, val);
                        }
                      },
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          widget.onEdit(widget.goal);
                        } else if (value == 'delete') {
                          widget.onDelete(widget.goal);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 20),
                              SizedBox(width: 8),
                              Text('Edit Goal'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline,
                                  color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text('Delete Goal',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Render children recursively if expanded
        if (hasChildren && _isExpanded)
          ...children.map(
            (child) => _GoalTreeNode(
              goal: child,
              allGoals: widget.allGoals,
              level: widget.level + 1,
              onGoalTap: widget.onGoalTap,
              onEdit: widget.onEdit,
              onDelete: widget.onDelete,
              onToggleComplete: widget.onToggleComplete,
            ),
          ),
      ],
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
