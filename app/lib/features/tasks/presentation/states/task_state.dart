import '../../domain/entities/task_entity.dart';

/// An immutable snapshot of the task feature state.
///
/// A state contains the currently loaded [tasks] list, the status of an active
/// repository operation, and an optional message for the most recent failure.
class TaskState {
  const TaskState._({
    this.tasks = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  /// Creates the initial state with an empty task list and no error.
  factory TaskState.initial() => const TaskState._();

  /// Creates a state representing an active task operation.
  factory TaskState.loading() => const TaskState._(isLoading: true);

  /// Creates a state containing the successfully loaded [tasks].
  factory TaskState.loaded(List<TaskEntity> tasks) =>
      TaskState._(tasks: tasks);

  /// Creates a failure state containing [message].
  factory TaskState.error(String message) =>
      TaskState._(errorMessage: message);

  /// The current list of tasks. Empty until successfully loaded.
  final List<TaskEntity> tasks;

  /// Whether a task operation is currently in progress.
  final bool isLoading;

  /// A message describing the latest task operation failure, if any.
  final String? errorMessage;

  /// Returns a copy of this state with the supplied fields replaced.
  TaskState copyWith({
    List<TaskEntity>? tasks,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TaskState._(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TaskState &&
            other.isLoading == isLoading &&
            other.errorMessage == errorMessage &&
            _listEquals(other.tasks, tasks);
  }

  @override
  int get hashCode => Object.hash(tasks, isLoading, errorMessage);

  static bool _listEquals(List<TaskEntity> a, List<TaskEntity> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
