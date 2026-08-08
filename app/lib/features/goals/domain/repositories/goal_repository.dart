import '../entities/goal_entity.dart';

/// Contract for managing goal operations.
abstract class GoalRepository {
  Future<List<GoalEntity>> getGoals(String userId);
  Future<void> addGoal(String userId, GoalEntity goal);
  Future<void> updateGoal(String userId, GoalEntity goal);
  Future<void> deleteGoal(String userId, String goalId);
}
