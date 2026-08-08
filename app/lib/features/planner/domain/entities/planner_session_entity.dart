import 'package:equatable/equatable.dart';

/// The type of activity a planner session represents.
enum SessionType {
  /// A focused study or work block linked to a task.
  study,

  /// A habit completion block.
  habit,

  /// A short break between focus blocks.
  breakTime,

  /// A meal period.
  meal,

  /// A physical exercise block.
  exercise,

  /// A sleep period.
  sleep,

  /// Any session that does not fit the other categories.
  other,
}

/// Energy level required or optimal for a session.
enum SessionEnergyLevel {
  /// Low energy session - light tasks, breaks, meals.
  low,

  /// Medium energy session - moderate focus required.
  medium,

  /// High energy session - deep work, complex problem-solving.
  high,
}

/// Immutable domain representation of a single planner session.
class PlannerSessionEntity extends Equatable {
  /// Creates a [PlannerSessionEntity].
  const PlannerSessionEntity({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.completed,
    this.linkedTaskId,
    this.linkedHabitId,
    this.reason,
    this.energyLevel,
    this.priority,
  });

  /// Unique identifier of the session.
  final String id;

  /// Display title shown in the timeline.
  final String title;

  /// When the session starts.
  final DateTime startTime;

  /// When the session ends.
  final DateTime endTime;

  /// The category of activity for this session.
  final SessionType type;

  /// Whether the session has been marked as completed.
  final bool completed;

  /// The id of the [TaskEntity] this session is associated with, if any.
  final String? linkedTaskId;

  /// The id of the [HabitEntity] this session is associated with, if any.
  final String? linkedHabitId;

  /// Explanation of why this session was scheduled at this time.
  /// Example: "Scheduled during morning high-energy window for deep work on
  /// Flutter architecture. Complex task requires uninterrupted focus."
  final String? reason;

  /// Energy level required or optimal for this session.
  final SessionEnergyLevel? energyLevel;

  /// Priority of the session (used for optimization and conflict resolution).
  final int? priority;

  /// Duration of the session.
  Duration get duration => endTime.difference(startTime);

  /// Whether the session is currently active (now is between start and end).
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  /// Whether the session has passed without being completed.
  bool get isPast => DateTime.now().isAfter(endTime) && !completed;

  /// Returns a copy of this session with [completed] set to `true`.
  PlannerSessionEntity markCompleted() {
    return PlannerSessionEntity(
      id: id,
      title: title,
      startTime: startTime,
      endTime: endTime,
      type: type,
      completed: true,
      linkedTaskId: linkedTaskId,
      linkedHabitId: linkedHabitId,
      reason: reason,
      energyLevel: energyLevel,
      priority: priority,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        startTime,
        endTime,
        type,
        completed,
        linkedTaskId,
        linkedHabitId,
        reason,
        energyLevel,
        priority,
      ];
}
