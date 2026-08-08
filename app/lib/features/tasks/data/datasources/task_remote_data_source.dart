import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/task_model.dart';

/// Defines remote persistence operations for user tasks.
abstract class TaskRemoteDataSource {
  /// Returns all tasks belonging to [uid].
  Future<List<TaskModel>> getTasks(String uid);

  /// Returns the task identified by [id] for [uid], or `null` if not found.
  Future<TaskModel?> getTask(String uid, String id);

  /// Persists [task] as a new task document for [uid].
  Future<void> createTask(String uid, TaskModel task);

  /// Updates the persisted data for [task] belonging to [uid].
  Future<void> updateTask(String uid, TaskModel task);

  /// Deletes the task identified by [id] for [uid].
  Future<void> deleteTask(String uid, String id);
}

/// Firestore implementation of [TaskRemoteDataSource].
class FirebaseTaskRemoteDataSource implements TaskRemoteDataSource {
  /// Creates a Firestore-backed task data source.
  FirebaseTaskRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  /// Returns the `users/{uid}/tasks` collection reference.
  CollectionReference<Map<String, dynamic>> _tasks(String uid) =>
      _firestore.collection('users').doc(uid).collection('tasks');

  @override
  Future<List<TaskModel>> getTasks(String uid) async {
    final snapshot = await _tasks(uid).get();
    return snapshot.docs
        .map((doc) => TaskModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<TaskModel?> getTask(String uid, String id) async {
    final snapshot = await _tasks(uid).doc(id).get();
    final data = snapshot.data();

    if (data == null) {
      return null;
    }

    return TaskModel.fromJson(data);
  }

  @override
  Future<void> createTask(String uid, TaskModel task) {
    return _tasks(uid).doc(task.id).set(task.toJson());
  }

  @override
  Future<void> updateTask(String uid, TaskModel task) {
    return _tasks(uid).doc(task.id).update(task.toJson());
  }

  @override
  Future<void> deleteTask(String uid, String id) {
    return _tasks(uid).doc(id).delete();
  }
}
