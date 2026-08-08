import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/goal_remote_data_source.dart';
import '../../data/repositories/goal_repository_impl.dart';
import '../../domain/repositories/goal_repository.dart';
import '../controllers/goal_controller.dart';
import '../states/goal_state.dart';

final goalRemoteDataSourceProvider = Provider<GoalRemoteDataSource>((ref) {
  return GoalRemoteDataSourceImpl();
});

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return GoalRepositoryImpl(ref.watch(goalRemoteDataSourceProvider));
});

final goalControllerProvider =
    NotifierProvider<GoalController, GoalState>(GoalController.new);
