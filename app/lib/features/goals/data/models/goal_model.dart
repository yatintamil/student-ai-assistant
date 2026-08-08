import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/goal_entity.dart';

/// Firestore data model for [GoalEntity].
class GoalModel {
  const GoalModel({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.category,
    this.targetDate,
    required this.isCompleted,
    required this.progress,
    this.parentGoalId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GoalModel.fromEntity(GoalEntity entity) {
    return GoalModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      level: entity.level.name,
      category: entity.category.name,
      targetDate: entity.targetDate,
      isCompleted: entity.isCompleted,
      progress: entity.progress,
      parentGoalId: entity.parentGoalId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory GoalModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return GoalModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      level: data['level'] as String? ?? GoalLevel.weekly.name,
      category: data['category'] as String? ?? GoalCategory.personal.name,
      targetDate: (data['targetDate'] as Timestamp?)?.toDate(),
      isCompleted: data['isCompleted'] as bool? ?? false,
      progress: (data['progress'] as num?)?.toDouble() ?? 0.0,
      parentGoalId: data['parentGoalId'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  final String id;
  final String title;
  final String description;
  final String level;
  final String category;
  final DateTime? targetDate;
  final bool isCompleted;
  final double progress;
  final String? parentGoalId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'level': level,
      'category': category,
      'targetDate': targetDate != null ? Timestamp.fromDate(targetDate!) : null,
      'isCompleted': isCompleted,
      'progress': progress,
      'parentGoalId': parentGoalId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  GoalEntity toEntity() {
    final parsedLevel = GoalLevel.values.firstWhere(
      (e) => e.name == level,
      orElse: () => GoalLevel.weekly,
    );
    final parsedCategory = GoalCategory.values.firstWhere(
      (e) => e.name == category,
      orElse: () => GoalCategory.personal,
    );

    return GoalEntity(
      id: id,
      title: title,
      description: description,
      level: parsedLevel,
      category: parsedCategory,
      targetDate: targetDate,
      isCompleted: isCompleted,
      progress: progress,
      parentGoalId: parentGoalId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
