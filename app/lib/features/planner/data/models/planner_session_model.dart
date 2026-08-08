import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/planner_session_entity.dart';

/// Firestore-backed representation of a [PlannerSessionEntity].
class PlannerSessionModel extends PlannerSessionEntity {
  /// Creates an immutable [PlannerSessionModel].
  const PlannerSessionModel({
    required super.id,
    required super.title,
    required super.startTime,
    required super.endTime,
    required super.type,
    required super.completed,
    super.linkedTaskId,
    super.linkedHabitId,
  });

  /// Creates a [PlannerSessionModel] from a domain [PlannerSessionEntity].
  factory PlannerSessionModel.fromEntity(PlannerSessionEntity entity) {
    return PlannerSessionModel(
      id: entity.id,
      title: entity.title,
      startTime: entity.startTime,
      endTime: entity.endTime,
      type: entity.type,
      completed: entity.completed,
      linkedTaskId: entity.linkedTaskId,
      linkedHabitId: entity.linkedHabitId,
    );
  }

  /// Creates a [PlannerSessionModel] from Firestore document data.
  factory PlannerSessionModel.fromJson(Map<String, dynamic> json) {
    return PlannerSessionModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      startTime: _dateTimeFromFirestore(json['startTime']),
      endTime: _dateTimeFromFirestore(json['endTime']),
      type: _typeFromString(json['type'] as String?),
      completed: json['completed'] as bool? ?? false,
      linkedTaskId: json['linkedTaskId'] as String?,
      linkedHabitId: json['linkedHabitId'] as String?,
    );
  }

  /// Converts this model to Firestore-compatible document data.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'type': type.name,
      'completed': completed,
      'linkedTaskId': linkedTaskId,
      'linkedHabitId': linkedHabitId,
    };
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static DateTime _dateTimeFromFirestore(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    throw ArgumentError.value(
      value,
      'value',
      'Expected a Firestore Timestamp or DateTime.',
    );
  }

  static SessionType _typeFromString(String? value) {
    return SessionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SessionType.other,
    );
  }
}
