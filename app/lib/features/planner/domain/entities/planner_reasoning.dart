import 'package:equatable/equatable.dart';

import 'planner_session_entity.dart';
import 'recommended_habit.dart';

/// Severity level of a scheduling warning.
enum WarningSeverity {
  /// Informational notice.
  info,

  /// Warning that should be addressed.
  warning,

  /// Critical issue that needs immediate attention.
  critical,
}

/// A warning or concern about the generated schedule.
class ScheduleWarning extends Equatable {
  /// Creates a schedule warning.
  const ScheduleWarning({
    required this.message,
    required this.severity,
    this.suggestion,
  });

  /// The warning message.
  final String message;

  /// Severity level of the warning.
  final WarningSeverity severity;

  /// Optional suggestion to resolve the warning.
  final String? suggestion;

  @override
  List<Object?> get props => [message, severity, suggestion];
}

/// Captures the AI's reasoning process and recommendations.
///
/// Stage 3 Output: This entity contains the AI's thought process, the generated
/// sessions, habit recommendations, scheduling explanations, and warnings.
class PlannerReasoning extends Equatable {
  /// Creates a planner reasoning result.
  const PlannerReasoning({
    required this.sessions,
    required this.reasoning,
    required this.orderRationale,
    required this.recommendedHabits,
    required this.warnings,
    required this.totalScheduledMinutes,
    required this.deepWorkBlocks,
    required this.breakCount,
  });

  /// The generated schedule sessions.
  final List<PlannerSessionEntity> sessions;

  /// Overall reasoning for the schedule structure.
  /// Example: "Scheduled high-priority Flutter task in morning when energy
  /// is highest, followed by habit blocks to maintain streaks."
  final String reasoning;

  /// Explanation of why sessions were ordered this way.
  /// Example: "Deep work placed before 12 PM. Exercise scheduled before
  /// long study sessions to boost focus. Similar tasks grouped to reduce
  /// context switching."
  final String orderRationale;

  /// Suggested habit improvements based on current vs. recommended habits.
  final List<RecommendedHabit> recommendedHabits;

  /// Warnings about the schedule.
  /// Examples:
  /// - "You only planned 5 hours of sleep."
  /// - "This deadline is unrealistic given available time."
  /// - "You have overloaded your afternoon."
  final List<ScheduleWarning> warnings;

  /// Total minutes scheduled (excluding sleep).
  final int totalScheduledMinutes;

  /// Number of deep work blocks (90+ minutes).
  final int deepWorkBlocks;

  /// Number of break sessions scheduled.
  final int breakCount;

  /// Whether the schedule has any critical warnings.
  bool get hasCriticalWarnings {
    return warnings.any((w) => w.severity == WarningSeverity.critical);
  }

  /// Whether the schedule is realistic and healthy.
  bool get isHealthy {
    return !hasCriticalWarnings && totalScheduledMinutes <= 720; // Max 12 hours
  }

  /// Creates a copy with updated fields.
  PlannerReasoning copyWith({
    List<PlannerSessionEntity>? sessions,
    String? reasoning,
    String? orderRationale,
    List<RecommendedHabit>? recommendedHabits,
    List<ScheduleWarning>? warnings,
    int? totalScheduledMinutes,
    int? deepWorkBlocks,
    int? breakCount,
  }) {
    return PlannerReasoning(
      sessions: sessions ?? this.sessions,
      reasoning: reasoning ?? this.reasoning,
      orderRationale: orderRationale ?? this.orderRationale,
      recommendedHabits: recommendedHabits ?? this.recommendedHabits,
      warnings: warnings ?? this.warnings,
      totalScheduledMinutes: totalScheduledMinutes ?? this.totalScheduledMinutes,
      deepWorkBlocks: deepWorkBlocks ?? this.deepWorkBlocks,
      breakCount: breakCount ?? this.breakCount,
    );
  }

  @override
  List<Object?> get props => [
        sessions,
        reasoning,
        orderRationale,
        recommendedHabits,
        warnings,
        totalScheduledMinutes,
        deepWorkBlocks,
        breakCount,
      ];
}
