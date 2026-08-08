import '../entities/task_entity.dart';

/// Defines persistence operations for user tasks.
abstract interface class TaskRepository {
  /// Returns all tasks belonging to [uid].
  Future<List<TaskEntity>> getTasks(String uid);

  /// Returns the task identified by [id] for [uid], or `null` if not found.
  Future<TaskEntity?> getTask(String uid, String id);

  /// Persists [task] as a new task document for [uid].
  Future<void> createTask(String uid, TaskEntity task);

  /// Updates the persisted data for [task] belonging to [uid].
  Future<void> updateTask(String uid, TaskEntity task);

  /// Deletes the task identified by [id] for [uid].
  Future<void> deleteTask(String uid, String id);
}
