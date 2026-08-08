import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../goals/presentation/providers/goal_providers.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../providers/task_providers.dart';
import '../states/task_state.dart';

/// Owns task presentation state and delegates task operations to a
/// [TaskRepository].
///
/// This Riverpod 3 [Notifier] resolves its repository through
/// [taskRepositoryProvider] in [build]. It does not access Firebase,
/// Firestore, UI classes, or navigation APIs.
class TaskController extends Notifier<TaskState> {
  late TaskRepository _repository;

  /// Initializes the controller with [TaskState.initial] and resolves its
  /// repository dependency from the provider graph.
  @override
  TaskState build() {
    _repository = ref.read(taskRepositoryProvider);
    return TaskState.initial();
  }

  // ---------------------------------------------------------------------------
  // Queries
  // ---------------------------------------------------------------------------

  /// Loads all tasks for [uid] and exposes them as [TaskState.loaded].
  Future<void> loadTasks(String uid) async {
    state = TaskState.loading();
    try {
      final tasks = await _repository.getTasks(uid);
      state = TaskState.loaded(tasks);
    } catch (error) {
      state = TaskState.error(_errorMessage(error));
    }
  }

  // ---------------------------------------------------------------------------
  // Mutations
  // ---------------------------------------------------------------------------

  /// Persists [task] for [uid] then reloads the task list.
  /// Recalculates progress for linked goal if applicable.
  Future<void> addTask(String uid, TaskEntity task) async {
    state = TaskState.loading();
    try {
      await _repository.createTask(uid, task);
      await _reload(uid);
      
      // Recalculate progress for linked goal
      if (task.goalId != null) {
        await _recalculateGoalProgress(uid, task.goalId!, state.tasks);
      }
    } catch (error) {
      state = TaskState.error(_errorMessage(error));
    }
  }

  /// Updates [task] for [uid] then reloads the task list.
  Future<void> updateTask(String uid, TaskEntity task) async {
    state = TaskState.loading();
    try {
      await _repository.updateTask(uid, task);
      await _reload(uid);
    } catch (error) {
      state = TaskState.error(_errorMessage(error));
    }
  }

  /// Deletes the task identified by [taskId] for [uid] then reloads the list.
/// Recalculates progress for linked goal if applicable.
Future<void> deleteTask(String uid, String taskId) async {
  // Get task before deleting to find its goalId
  final taskToDelete = state.tasks.cast<TaskEntity?>().firstWhere(
        (t) => t?.id == taskId,
        orElse: () => null,
      );
  final goalId = taskToDelete?.goalId;
  
  state = TaskState.loading();
  try {
    await _repository.deleteTask(uid, taskId);
    await _reload(uid);
    
    // Recalculate progress for linked goal
    if (goalId != null) {
      await _recalculateGoalProgress(uid, goalId, state.tasks);
    }
  } catch (error) {
    state = TaskState.error(_errorMessage(error));
  }
}

  /// Toggles [task] between [TaskStatus.pending] and [TaskStatus.completed]
  /// for [uid], then reloads the task list.
  /// 
  /// Also recalculates progress for any linked goal.
  Future<void> toggleCompleted(String uid, TaskEntity task) async {
    final toggled = _toggleStatus(task);
    await updateTask(uid, toggled);
    
    // Recalculate progress for any linked goal
    if (task.goalId != null) {
      final currentTasks = state.tasks;
      await _recalculateGoalProgress(uid, task.goalId!, currentTasks);
    }
  }
  
  /// Recalculates the progress for a goal based on its linked tasks
  Future<void> _recalculateGoalProgress(
    String uid,
    String goalId,
    List<TaskEntity> allTasks,
  ) async {
    final linkedTasks = allTasks.where((t) => t.goalId == goalId).toList();
    if (linkedTasks.isEmpty) return;
    
    // Get the goal controller and update the goal progress
    ref.read(goalControllerProvider.notifier).recalculateGoalProgress(
      uid,
      goalId,
      linkedTasks.cast<dynamic>(),
    );
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Re-fetches the task list and updates state without the loading flash
  /// (used internally after a successful mutation).
  Future<void> _reload(String uid) async {
    final tasks = await _repository.getTasks(uid);
    state = TaskState.loaded(tasks);
  }

  TaskEntity _toggleStatus(TaskEntity task) {
    final next = task.status == TaskStatus.pending
        ? TaskStatus.completed
        : TaskStatus.pending;

    return TaskEntity(
      id: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      estimatedMinutes: task.estimatedMinutes,
      priority: task.priority,
      status: next,
      category: task.category,
      createdAt: task.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  String _errorMessage(Object error) {
    if (error is String) return error;
    return 'Something went wrong. Please try again.';
  }
}
