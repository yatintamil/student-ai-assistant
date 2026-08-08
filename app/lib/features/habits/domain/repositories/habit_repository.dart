import '../entities/habit_entity.dart';

/// Defines persistence operations for user habits.
abstract interface class HabitRepository {
  /// Returns all habits belonging to [uid].
  Future<List<HabitEntity>> getHabits(String uid);

  /// Returns the habit identified by [id] for [uid], or `null` if not found.
  Future<HabitEntity?> getHabit(String uid, String id);

  /// Persists [habit] as a new habit document for [uid].
  Future<void> createHabit(String uid, HabitEntity habit);

  /// Updates the persisted data for [habit] belonging to [uid].
  Future<void> updateHabit(String uid, HabitEntity habit);

  /// Deletes the habit identified by [id] for [uid].
  Future<void> deleteHabit(String uid, String id);
}
