import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../domain/entities/task_entity.dart';
import '../providers/task_providers.dart';
import '../states/task_state.dart';
import '../widgets/task_empty_state.dart';
import '../widgets/task_tile.dart';
import 'add_task_page.dart';
import 'edit_task_page.dart';

/// Displays the authenticated user's task list.
///
/// - FAB navigates to [AddTaskPage].
/// - Tapping a tile navigates to [EditTaskPage].
/// - Checking the checkbox toggles the task between pending and completed.
/// - Swiping a tile left reveals a delete action.
class TaskListPage extends ConsumerStatefulWidget {
  /// Creates the task list page.
  const TaskListPage({super.key});

  @override
  ConsumerState<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends ConsumerState<TaskListPage> {
  @override
  void initState() {
    super.initState();
    // Defer the first load so the widget tree is fully mounted.
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTasks());
  }

  String? get _uid => ref.read(authControllerProvider).user?.id;

  void _loadTasks() {
    final uid = _uid;
    if (uid == null) return;
    ref.read(taskControllerProvider.notifier).loadTasks(uid);
  }

  Future<void> _deleteTask(TaskEntity task) async {
    final uid = _uid;
    if (uid == null) return;
    await ref.read(taskControllerProvider.notifier).deleteTask(uid, task.id);
  }

  Future<void> _toggleCompleted(TaskEntity task) async {
    final uid = _uid;
    if (uid == null) return;
    await ref
        .read(taskControllerProvider.notifier)
        .toggleCompleted(uid, task);
  }

  void _navigateToAdd() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AddTaskPage()),
    );
  }

  void _navigateToEdit(TaskEntity task) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => EditTaskPage(task: task)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: <Widget>[
          if (taskState.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: _buildBody(taskState, colorScheme),
      floatingActionButton: FloatingActionButton(
        heroTag: 'taskListFab',
        onPressed: _navigateToAdd,
        tooltip: 'Add task',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(TaskState taskState, ColorScheme colorScheme) {
    if (taskState.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.error_outline, size: 48, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(
                taskState.errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadTasks,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final tasks = taskState.tasks;

    if (!taskState.isLoading && tasks.isEmpty) {
      return const TaskEmptyState();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth >= 600 ? 32.0 : 0.0;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView.separated(
              padding: EdgeInsets.only(
                left: horizontalPadding,
                right: horizontalPadding,
                top: 8,
                bottom: 96,
              ),
              itemCount: tasks.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Dismissible(
                  key: ValueKey(task.id),
                  direction: DismissDirection.endToStart,
                  background: _buildDismissBackground(colorScheme),
                  confirmDismiss: (_) => _confirmDelete(context),
                  onDismissed: (_) => _deleteTask(task),
                  child: TaskTile(
                    task: task,
                    onToggleCompleted: () => _toggleCompleted(task),
                    onTap: () => _navigateToEdit(task),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildDismissBackground(ColorScheme colorScheme) {
    return ColoredBox(
      color: colorScheme.errorContainer,
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Icon(
            Icons.delete_outline,
            color: colorScheme.onErrorContainer,
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete task'),
        content: const Text('This task will be permanently deleted.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
