import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/goal_model.dart';

abstract class GoalRemoteDataSource {
  Future<List<GoalModel>> getGoals(String userId);
  Future<void> addGoal(String userId, GoalModel goal);
  Future<void> updateGoal(String userId, GoalModel goal);
  Future<void> deleteGoal(String userId, String goalId);
}

class GoalRemoteDataSourceImpl implements GoalRemoteDataSource {
  GoalRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore.collection('users').doc(userId).collection('goals');
  }

  @override
  Future<List<GoalModel>> getGoals(String userId) async {
    final snapshot = await _collection(userId)
        .orderBy('updatedAt', descending: true)
        .get();
    return snapshot.docs.map(GoalModel.fromFirestore).toList();
  }

  @override
  Future<void> addGoal(String userId, GoalModel goal) async {
    await _collection(userId).doc(goal.id).set(goal.toMap());
  }

  @override
  Future<void> updateGoal(String userId, GoalModel goal) async {
    await _collection(userId).doc(goal.id).update(goal.toMap());
  }

  @override
  Future<void> deleteGoal(String userId, String goalId) async {
    await _collection(userId).doc(goalId).delete();
  }
}
