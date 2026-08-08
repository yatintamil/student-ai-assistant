import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/habit_entity.dart';
import '../../domain/repositories/habit_repository.dart';
import '../providers/habit_providers.dart';
import '../states/habit_state.dart';

/// Owns habit presentation state and delegates habit operations to a
/// [HabitRepository].
///
/// This Riverpod 3 [Notifier] resolves its repository through
/// [habitRepositoryProvider] in [build]. It does not access Firebase,
/// Firestore, UI classes, or navigation APIs.
class HabitController extends Notifier<HabitState> {
  late HabitRepository _repository;

  @override
  HabitState build() {
    _repository = ref.read(habitRepositoryProvider);
    return HabitState.initial();
  }

  // ---------------------------------------------------------------------------
  // Queries
  // ---------------------------------------------------------------------------

  /// Loads all habits for [uid] and exposes them as [HabitState.loaded].
  Future<void> loadHabits(String uid) async {
    state = HabitState.loading();
    try {
      final habits = await _repository.getHabits(uid);
      state = HabitState.loaded(habits);
    } catch (error) {
      state = HabitState.error(_errorMessage(error));
    }
  }

  // ---------------------------------------------------------------------------
  // Mutations
  // ---------------------------------------------------------------------------

  /// Persists [habit] for [uid] then reloads the habit list.
  Future<void> addHabit(String uid, HabitEntity habit) async {
    state = HabitState.loading();
    try {
      await _repository.createHabit(uid, habit);
      await _reload(uid);
    } catch (error) {
      state = HabitState.error(_errorMessage(error));
    }
  }

  /// Updates [habit] for [uid] then reloads the habit list.
  Future<void> updateHabit(String uid, HabitEntity habit) async {
    state = HabitState.loading();
    try {
      await _repository.updateHabit(uid, habit);
      await _reload(uid);
    } catch (error) {
      state = HabitState.error(_errorMessage(error));
    }
  }

  /// Deletes the habit identified by [habitId] for [uid] then reloads the
  /// list.
  Future<void> deleteHabit(String uid, String habitId) async {
    state = HabitState.loading();
    try {
      await _repository.deleteHabit(uid, habitId);
      await _reload(uid);
    } catch (error) {
      state = HabitState.error(_errorMessage(error));
    }
  }

  /// Toggles today's completion for [habit].
  ///
  /// If the habit is already completed today the today-date is removed from
  /// [HabitEntity.completedDates] and the streak is decremented. Otherwise
  /// today is added and the streak is incremented. Calls [updateHabit]
  /// internally so the change is persisted and the list reloads automatically.
  Future<void> toggleCompletedToday(String uid, HabitEntity habit) async {
    final toggled = _applyTodayToggle(habit);
    await updateHabit(uid, toggled);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<void> _reload(String uid) async {
    final habits = await _repository.getHabits(uid);
    state = HabitState.loaded(habits);
  }

  HabitEntity _applyTodayToggle(HabitEntity habit) {
    final today = _utcMidnight(DateTime.now());
    final alreadyDone =
        habit.completedDates.any((d) => _utcMidnight(d) == today);

    final List<DateTime> updatedDates;
    final int updatedStreak;

    if (alreadyDone) {
      updatedDates = habit.completedDates
          .where((d) => _utcMidnight(d) != today)
          .toList();
      updatedStreak = (habit.currentStreak - 1).clamp(0, double.infinity).toInt();
    } else {
      updatedDates = [...habit.completedDates, today];
      updatedStreak = habit.currentStreak + 1;
    }

    final newLongest = updatedStreak > habit.longestStreak
        ? updatedStreak
        : habit.longestStreak;

    return HabitEntity(
      id: habit.id,
      title: habit.title,
      description: habit.description,
      frequency: habit.frequency,
      targetDays: habit.targetDays,
      currentStreak: updatedStreak,
      longestStreak: newLongest,
      completedDates: updatedDates,
      color: habit.color,
      iconName: habit.iconName,
      createdAt: habit.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  static DateTime _utcMidnight(DateTime dt) =>
      DateTime.utc(dt.year, dt.month, dt.day);

  String _errorMessage(Object error) {
    if (error is String) return error;
    return 'Something went wrong. Please try again.';
  }
}
