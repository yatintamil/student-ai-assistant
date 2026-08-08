import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/life_context/life_context_providers.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../domain/entities/goal_entity.dart';
import '../providers/goal_providers.dart';
import '../widgets/goal_hierarchy_widget.dart';
import 'goal_detail_page.dart';
import 'weekly_review_page.dart';

class GoalListPage extends ConsumerStatefulWidget {
  const GoalListPage({super.key});

  @override
  ConsumerState<GoalListPage> createState() => _GoalListPageState();
}

class _GoalListPageState extends ConsumerState<GoalListPage> {
  bool _showHierarchy = true; // Toggle between hierarchy and flat view

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGoals();
    });
  }

  void _loadGoals() {
    final uid = ref.read(authControllerProvider).user?.id;
    if (uid != null) {
      ref.read(goalControllerProvider.notifier).loadGoals(uid);
    }
  }

  void _showGoalDialog([GoalEntity? existingGoal]) {
    final titleController = TextEditingController(text: existingGoal?.title ?? '');
    final descController = TextEditingController(text: existingGoal?.description ?? '');
    GoalLevel selectedLevel = existingGoal?.level ?? GoalLevel.weekly;
    GoalCategory selectedCategory = existingGoal?.category ?? GoalCategory.personal;
    String? selectedParentId = existingGoal?.parentGoalId;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(existingGoal == null ? 'Add New Goal' : 'Edit Goal'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Goal Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Description / Purpose',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<GoalLevel>(
                      initialValue: selectedLevel,
                      decoration: const InputDecoration(labelText: 'Goal Level'),
                      items: GoalLevel.values.map((l) {
                        return DropdownMenuItem(
                          value: l,
                          child: Text(l.name.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedLevel = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<GoalCategory>(
                      initialValue: selectedCategory,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: GoalCategory.values.map((c) {
                        return DropdownMenuItem(
                          value: c,
                          child: Text(c.name.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedCategory = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String?>(
                      value: selectedParentId,
                      decoration: const InputDecoration(
                        labelText: 'Parent Goal (Optional)',
                        helperText: 'Link this to a higher-level goal',
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('None (Root Goal)'),
                        ),
                        ...ref.watch(goalControllerProvider).goals
                            .where((g) => g.id != existingGoal?.id) // Don't allow self-parenting
                            .map((g) => DropdownMenuItem<String?>(
                                  value: g.id,
                                  child: Text('[${g.level.name.toUpperCase()}] ${g.title}'),
                                )),
                      ],
                      onChanged: (val) {
                        setDialogState(() => selectedParentId = val);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final uid = ref.read(authControllerProvider).user?.id;
                    if (uid == null || titleController.text.trim().isEmpty) return;

                    if (existingGoal == null) {
                      final newGoal = GoalEntity(
                        id: const Uuid().v4(),
                        title: titleController.text.trim(),
                        description: descController.text.trim(),
                        level: selectedLevel,
                        category: selectedCategory,
                        parentGoalId: selectedParentId,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      );
                      await ref.read(goalControllerProvider.notifier).addGoal(uid, newGoal);
                    } else {
                      final updated = existingGoal.copyWith(
                        title: titleController.text.trim(),
                        description: descController.text.trim(),
                        level: selectedLevel,
                        category: selectedCategory,
                        parentGoalId: selectedParentId,
                        updatedAt: DateTime.now(),
                      );
                      await ref.read(goalControllerProvider.notifier).updateGoal(uid, updated);
                    }
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: Text(existingGoal == null ? 'Save Goal' : 'Update Goal'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteGoal(GoalEntity goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal?'),
        content: Text('Are you sure you want to delete "${goal.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final uid = ref.read(authControllerProvider).user?.id;
              if (uid != null) {
                await ref.read(goalControllerProvider.notifier).deleteGoal(uid, goal.id);
              }
              if (context.mounted) Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showWeeklyReviewDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const WeeklyReviewPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goalState = ref.watch(goalControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal Management & Vision'),
        actions: [
          IconButton(
            icon: Icon(_showHierarchy ? Icons.list : Icons.account_tree),
            tooltip: _showHierarchy ? 'Switch to List View' : 'Switch to Tree View',
            onPressed: () {
              setState(() => _showHierarchy = !_showHierarchy);
            },
          ),
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'Weekly Goal Review',
            onPressed: _showWeeklyReviewDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'goalListFab',
        onPressed: () => _showGoalDialog(),
        icon: const Icon(Icons.flag_outlined),
        label: const Text('New Goal'),
      ),
      body: goalState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : goalState.goals.isEmpty
              ? _buildEmptyState(theme)
              : _showHierarchy
                  ? _buildGoalHierarchy(goalState.goals)
                  : _buildGoalList(goalState.goals, theme),
    );
  }

  Widget _buildGoalHierarchy(List<GoalEntity> goals) {
    return GoalHierarchyWidget(
      goals: goals,
      onGoalTap: (goal) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GoalDetailPage(goal: goal),
          ),
        );
      },
      onEdit: _showGoalDialog,
      onDelete: _confirmDeleteGoal,
      onToggleComplete: (goal, isCompleted) async {
        final uid = ref.read(authControllerProvider).user?.id;
        if (uid != null) {
          final updated = goal.copyWith(
            isCompleted: isCompleted,
            progress: isCompleted ? 1.0 : goal.progress,
            updatedAt: DateTime.now(),
          );
          await ref.read(goalControllerProvider.notifier).updateGoal(uid, updated);
        }
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.stars_outlined, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'No Goals Defined Yet',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Define your long-term vision, quarterly objectives, and weekly targets so your AI Chief of Staff can align every daily activity.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showGoalDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Define Your First Goal'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalList(List<GoalEntity> goals, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                _getCategoryIcon(goal.category),
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            title: Text(
              goal.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                decoration: goal.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (goal.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(goal.description),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Chip(
                      label: Text(
                        goal.level.name.toUpperCase(),
                        style: const TextStyle(fontSize: 10),
                      ),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(goal.progress * 100).toInt()}% Done',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: goal.isCompleted,
                  onChanged: (val) async {
                    final uid = ref.read(authControllerProvider).user?.id;
                    if (uid != null && val != null) {
                      final updated = goal.copyWith(
                        isCompleted: val,
                        progress: val ? 1.0 : 0.0,
                        updatedAt: DateTime.now(),
                      );
                      await ref.read(goalControllerProvider.notifier).updateGoal(uid, updated);
                    }
                  },
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showGoalDialog(goal);
                    } else if (value == 'delete') {
                      _confirmDeleteGoal(goal);
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
                          Icon(Icons.delete_outline, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Delete Goal', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
