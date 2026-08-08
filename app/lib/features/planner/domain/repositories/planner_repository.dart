import '../entities/planner_session_entity.dart';

/// Defines persistence operations for planner sessions.
abstract interface class PlannerRepository {
  /// Returns all sessions planned for [date] belonging to [uid].
  Future<List<PlannerSessionEntity>> getSessionsForDate(
    String uid,
    DateTime date,
  );

  /// Persists a list of [sessions] for [uid] replacing any existing plan for
  /// the same date.
  Future<void> saveSessions(
    String uid,
    List<PlannerSessionEntity> sessions,
  );

  /// Marks the session identified by [sessionId] as completed for [uid].
  Future<void> markSessionCompleted(String uid, String sessionId);

  /// Deletes all sessions for [uid] on [date].
  Future<void> clearSessionsForDate(String uid, DateTime date);
}
