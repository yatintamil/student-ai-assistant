import '../../domain/entities/goal_entity.dart';
import '../../domain/repositories/goal_repository.dart';
import '../datasources/goal_remote_data_source.dart';
import '../models/goal_model.dart';

class GoalRepositoryImpl implements GoalRepository {
  const GoalRepositoryImpl(this._remoteDataSource);

  final GoalRemoteDataSource _remoteDataSource;

  @override
  Future<List<GoalEntity>> getGoals(String userId) async {
    final models = await _remoteDataSource.getGoals(userId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> addGoal(String userId, GoalEntity goal) async {
    final model = GoalModel.fromEntity(goal);
    await _remoteDataSource.addGoal(userId, model);
  }

  @override
  Future<void> updateGoal(String userId, GoalEntity goal) async {
    final model = GoalModel.fromEntity(goal);
    await _remoteDataSource.updateGoal(userId, model);
  }

  @override
  Future<void> deleteGoal(String userId, String goalId) async {
    await _remoteDataSource.deleteGoal(userId, goalId);
  }
}
