import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/habit_model.dart';

/// Defines remote persistence operations for user habits.
abstract class HabitRemoteDataSource {
  /// Returns all habits belonging to [uid].
  Future<List<HabitModel>> getHabits(String uid);

  /// Returns the habit identified by [id] for [uid], or `null` if not found.
  Future<HabitModel?> getHabit(String uid, String id);

  /// Persists [habit] as a new habit document for [uid].
  Future<void> createHabit(String uid, HabitModel habit);

  /// Updates the persisted data for [habit] belonging to [uid].
  Future<void> updateHabit(String uid, HabitModel habit);

  /// Deletes the habit identified by [id] for [uid].
  Future<void> deleteHabit(String uid, String id);
}

/// Firestore implementation of [HabitRemoteDataSource].
///
/// Collection path: `users/{uid}/habits`
class FirebaseHabitRemoteDataSource implements HabitRemoteDataSource {
  /// Creates a Firestore-backed habit data source.
  FirebaseHabitRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  /// Returns the `users/{uid}/habits` collection reference.
  CollectionReference<Map<String, dynamic>> _habits(String uid) =>
      _firestore.collection('users').doc(uid).collection('habits');

  @override
  Future<List<HabitModel>> getHabits(String uid) async {
    final snapshot = await _habits(uid).get();
    return snapshot.docs
        .map((doc) => HabitModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<HabitModel?> getHabit(String uid, String id) async {
    final snapshot = await _habits(uid).doc(id).get();
    final data = snapshot.data();
    if (data == null) return null;
    return HabitModel.fromJson(data);
  }

  @override
  Future<void> createHabit(String uid, HabitModel habit) {
    return _habits(uid).doc(habit.id).set(habit.toJson());
  }

  @override
  Future<void> updateHabit(String uid, HabitModel habit) {
    return _habits(uid).doc(habit.id).update(habit.toJson());
  }

  @override
  Future<void> deleteHabit(String uid, String id) {
    return _habits(uid).doc(id).delete();
  }
}
