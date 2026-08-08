import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/goal_entity.dart';
import '../../domain/repositories/goal_repository.dart';
import '../providers/goal_providers.dart';
import '../states/goal_state.dart';

class GoalController extends Notifier<GoalState> {
  late GoalRepository _repository;

  @override
  GoalState build() {
    _repository = ref.read(goalRepositoryProvider);
    return const GoalState();
  }

  Future<void> loadGoals(String userId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final goals = await _repository.getGoals(userId);
      state = state.copyWith(goals: goals, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load goals: $e',
      );
    }
  }

  Future<void> addGoal(String userId, GoalEntity goal) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.addGoal(userId, goal);
      await loadGoals(userId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to add goal: $e',
      );
    }
  }

  Future<void> updateGoal(String userId, GoalEntity goal) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.updateGoal(userId, goal);
      await loadGoals(userId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update goal: $e',
      );
    }
  }

  Future<void> deleteGoal(String userId, String goalId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.deleteGoal(userId, goalId);
      await loadGoals(userId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to delete goal: $e',
      );
    }
  }

  Future<void> recalculateGoalProgress(
    String userId,
    String goalId,
    List<dynamic> allTasks,
  ) async {
    final goal = state.goals.cast<GoalEntity?>().firstWhere(
          (g) => g?.id == goalId,
          orElse: () => null,
        );
    if (goal == null) return;

    final linkedTasks = allTasks.where((t) => t.goalId == goalId).toList();
    if (linkedTasks.isEmpty) return;

    final completedCount =
        linkedTasks.where((t) => t.status.name == 'completed').length;
    final newProgress = completedCount / linkedTasks.length;
    final isDone = newProgress >= 1.0;

    if (goal.progress != newProgress || goal.isCompleted != isDone) {
      final updated = goal.copyWith(
        progress: newProgress,
        isCompleted: isDone,
        updatedAt: DateTime.now(),
      );
      await updateGoal(userId, updated);
    }
  }
}
