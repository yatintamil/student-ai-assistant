import 'package:equatable/equatable.dart';

/// The priority level assigned to a task.
enum TaskPriority {
  low,
  medium,
  high,
}

/// The completion status of a task.
enum TaskStatus {
  pending,
  completed,
}

/// Immutable domain representation of a task.
class TaskEntity extends Equatable {
  const TaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.estimatedMinutes,
    required this.priority,
    required this.status,
    required this.category,
    this.goalId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final int estimatedMinutes;
  final TaskPriority priority;
  final TaskStatus status;
  final String category;

  /// Optional link connecting this task to a Goal.
  final String? goalId;

  final DateTime createdAt;
  final DateTime updatedAt;

  TaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    int? estimatedMinutes,
    TaskPriority? priority,
    TaskStatus? status,
    String? category,
    String? goalId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      category: category ?? this.category,
      goalId: goalId ?? this.goalId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        dueDate,
        estimatedMinutes,
        priority,
        status,
        category,
        goalId,
        createdAt,
        updatedAt,
      ];
}
