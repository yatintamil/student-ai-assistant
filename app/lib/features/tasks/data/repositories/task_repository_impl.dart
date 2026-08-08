import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_data_source.dart';
import '../models/task_model.dart';

/// Data-layer implementation of [TaskRepository].
///
/// Converts between domain [TaskEntity] objects and data [TaskModel] objects,
/// while delegating all persistence to [TaskRemoteDataSource]. The repository
/// does not access the Firestore SDK directly, which keeps it independently
/// testable with a fake or mocked data source.
class TaskRepositoryImpl implements TaskRepository {
  /// Creates a repository backed by the injected [remoteDataSource].
  TaskRepositoryImpl(this._remoteDataSource);

  final TaskRemoteDataSource _remoteDataSource;

  /// Fetches all tasks for [uid] and maps them to domain entities.
  @override
  Future<List<TaskEntity>> getTasks(String uid) async {
    final models = await _remoteDataSource.getTasks(uid);
    return models.map(_toEntity).toList();
  }

  /// Fetches the task identified by [id] for [uid], mapped to a domain entity.
  @override
  Future<TaskEntity?> getTask(String uid, String id) async {
    final model = await _remoteDataSource.getTask(uid, id);
    return model == null ? null : _toEntity(model);
  }

  /// Maps [task] to a model and persists it through the data source.
  @override
  Future<void> createTask(String uid, TaskEntity task) {
    return _remoteDataSource.createTask(uid, _toModel(task));
  }

  /// Maps [task] to a model and updates it through the data source.
  @override
  Future<void> updateTask(String uid, TaskEntity task) {
    return _remoteDataSource.updateTask(uid, _toModel(task));
  }

  /// Deletes the task identified by [id] for [uid] through the data source.
  @override
  Future<void> deleteTask(String uid, String id) {
    return _remoteDataSource.deleteTask(uid, id);
  }

  // ---------------------------------------------------------------------------
  // Private mapping helpers
  // ---------------------------------------------------------------------------

  /// Converts a data-layer [TaskModel] to a domain [TaskEntity].
  TaskEntity _toEntity(TaskModel model) {
    return TaskEntity(
      id: model.id,
      title: model.title,
      description: model.description,
      dueDate: model.dueDate,
      estimatedMinutes: model.estimatedMinutes,
      priority: model.priority,
      status: model.status,
      category: model.category,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  /// Converts a domain [TaskEntity] to a data-layer [TaskModel].
  TaskModel _toModel(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      dueDate: entity.dueDate,
      estimatedMinutes: entity.estimatedMinutes,
      priority: entity.priority,
      status: entity.status,
      category: entity.category,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
