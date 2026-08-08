import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/task_entity.dart';

/// Firestore-backed representation of a task.
class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.title,
    required super.description,
    required super.dueDate,
    required super.estimatedMinutes,
    required super.priority,
    required super.status,
    required super.category,
    super.goalId,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      dueDate: _dateTimeFromFirestore(json['dueDate']),
      estimatedMinutes: json['estimatedMinutes'] as int? ?? 0,
      priority: _priorityFromString(json['priority'] as String?),
      status: _statusFromString(json['status'] as String?),
      category: json['category'] as String? ?? '',
      goalId: json['goalId'] as String?,
      createdAt: _dateTimeFromFirestore(json['createdAt']),
      updatedAt: _dateTimeFromFirestore(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'estimatedMinutes': estimatedMinutes,
      'priority': priority.name,
      'status': status.name,
      'category': category,
      'goalId': goalId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static DateTime _dateTimeFromFirestore(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return DateTime.now();
  }

  static TaskPriority _priorityFromString(String? value) {
    return TaskPriority.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TaskPriority.medium,
    );
  }

  static TaskStatus _statusFromString(String? value) {
    return TaskStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TaskStatus.pending,
    );
  }
}
