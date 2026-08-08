import 'package:equatable/equatable.dart';

/// The hierarchy level of a goal in the user's Life OS.
enum GoalLevel {
  vision,
  longTerm,
  quarterly,
  monthly,
  weekly,
  daily,
}

/// Life domain categories for goals.
enum GoalCategory {
  career,
  education,
  health,
  personal,
  finance,
  business,
  projects,
  other,
}

/// Domain entity representing a goal in the Personal Chief of Staff system.
class GoalEntity extends Equatable {
  const GoalEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.category,
    this.targetDate,
    this.isCompleted = false,
    this.progress = 0.0,
    this.parentGoalId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final GoalLevel level;
  final GoalCategory category;
  final DateTime? targetDate;
  final bool isCompleted;

  /// Progress from 0.0 to 1.0 (0% to 100%).
  final double progress;

  /// Parent goal ID for supporting goal hierarchy (e.g. Weekly -> Monthly -> Quarterly -> Vision).
  final String? parentGoalId;

  final DateTime createdAt;
  final DateTime updatedAt;

  GoalEntity copyWith({
    String? id,
    String? title,
    String? description,
    GoalLevel? level,
    GoalCategory? category,
    DateTime? targetDate,
    bool? isCompleted,
    double? progress,
    String? parentGoalId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GoalEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      level: level ?? this.level,
      category: category ?? this.category,
      targetDate: targetDate ?? this.targetDate,
      isCompleted: isCompleted ?? this.isCompleted,
      progress: progress ?? this.progress,
      parentGoalId: parentGoalId ?? this.parentGoalId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        level,
        category,
        targetDate,
        isCompleted,
        progress,
        parentGoalId,
        createdAt,
        updatedAt,
      ];
}
