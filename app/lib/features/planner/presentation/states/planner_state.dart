import '../../domain/entities/planner_reasoning.dart';
import '../../domain/entities/planner_session_entity.dart';
import '../../domain/entities/recommended_habit.dart';

/// An immutable snapshot of the planner feature state.
class PlannerState {
  const PlannerState._({
    this.sessions = const [],
    this.isLoading = false,
    this.errorMessage,
    this.reasoning,
    this.orderRationale,
    this.recommendedHabits = const [],
    this.warnings = const [],
  });

  /// Creates the initial state — empty plan, no error.
  factory PlannerState.initial() => const PlannerState._();

  /// Creates a loading state.
  factory PlannerState.loading() => const PlannerState._(isLoading: true);

  /// Creates a state containing the generated or loaded [sessions].
  factory PlannerState.loaded(List<PlannerSessionEntity> sessions) =>
      PlannerState._(sessions: sessions);

  /// Creates a state with full reasoning from AI planner.
  factory PlannerState.loadedWithReasoning(PlannerReasoning plannerReasoning) =>
      PlannerState._(
        sessions: plannerReasoning.sessions,
        reasoning: plannerReasoning.reasoning,
        orderRationale: plannerReasoning.orderRationale,
        recommendedHabits: plannerReasoning.recommendedHabits,
        warnings: plannerReasoning.warnings,
      );

  /// Creates a failure state containing [message].
  factory PlannerState.error(String message) =>
      PlannerState._(errorMessage: message);

  /// The ordered list of sessions for today. Empty until generated.
  final List<PlannerSessionEntity> sessions;

  /// Whether a plan operation is currently in progress.
  final bool isLoading;

  /// A message describing the latest operation failure, if any.
  final String? errorMessage;

  /// Overall reasoning for the schedule structure from AI.
  final String? reasoning;

  /// Explanation of why sessions were ordered this way.
  final String? orderRationale;

  /// Suggested habit improvements based on current vs. recommended habits.
  final List<RecommendedHabit> recommendedHabits;

  /// Warnings about the schedule (sleep, overload, unrealistic deadlines).
  final List<ScheduleWarning> warnings;

  /// Whether the schedule has any critical warnings.
  bool get hasCriticalWarnings {
    return warnings.any((w) => w.severity == WarningSeverity.critical);
  }

  /// Whether the schedule has any warnings at all.
  bool get hasWarnings => warnings.isNotEmpty;

  /// The session that is currently active (now between start and end), or
  /// `null` if no session is active.
  PlannerSessionEntity? get currentSession {
    try {
      return sessions.firstWhere((s) => s.isActive);
    } catch (_) {
      return null;
    }
  }

  /// The next upcoming (not yet started, not completed) session, or `null`.
  PlannerSessionEntity? get nextSession {
    final now = DateTime.now();
    try {
      return sessions.firstWhere(
        (s) => s.startTime.isAfter(now) && !s.completed,
      );
    } catch (_) {
      return null;
    }
  }

  /// Returns a new state with [sessions] updated so the session matching
  /// [sessionId] is marked completed.
  PlannerState withSessionCompleted(String sessionId) {
    final updated = sessions.map((s) {
      return s.id == sessionId ? s.markCompleted() : s;
    }).toList();
    return PlannerState._(
      sessions: updated,
      isLoading: isLoading,
      errorMessage: errorMessage,
      reasoning: reasoning,
      orderRationale: orderRationale,
      recommendedHabits: recommendedHabits,
      warnings: warnings,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PlannerState &&
            other.isLoading == isLoading &&
            other.errorMessage == errorMessage &&
            other.reasoning == reasoning &&
            other.orderRationale == orderRationale &&
            _listEquals(other.sessions, sessions) &&
            _listEqualsHabits(other.recommendedHabits, recommendedHabits) &&
            _listEqualsWarnings(other.warnings, warnings);
  }

  @override
  int get hashCode => Object.hash(
        sessions,
        isLoading,
        errorMessage,
        reasoning,
        orderRationale,
        recommendedHabits,
        warnings,
      );

  static bool _listEquals(
    List<PlannerSessionEntity> a,
    List<PlannerSessionEntity> b,
  ) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _listEqualsHabits(
    List<RecommendedHabit> a,
    List<RecommendedHabit> b,
  ) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _listEqualsWarnings(
    List<ScheduleWarning> a,
    List<ScheduleWarning> b,
  ) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
