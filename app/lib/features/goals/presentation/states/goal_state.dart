import 'package:equatable/equatable.dart';

import '../../domain/entities/goal_entity.dart';

class GoalState extends Equatable {
  const GoalState({
    this.goals = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<GoalEntity> goals;
  final bool isLoading;
  final String? errorMessage;

  GoalState copyWith({
    List<GoalEntity>? goals,
    bool? isLoading,
    String? errorMessage,
  }) {
    return GoalState(
      goals: goals ?? this.goals,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [goals, isLoading, errorMessage];
}
