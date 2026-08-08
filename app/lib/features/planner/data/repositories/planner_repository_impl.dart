import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/planner_session_entity.dart';
import '../../domain/repositories/planner_repository.dart';
import '../models/planner_session_model.dart';

/// Firestore-backed implementation of [PlannerRepository].
///
/// Sessions are stored under `users/{uid}/planner/{dateKey}/sessions/{id}`.
/// The [dateKey] is formatted as `yyyy-MM-dd` so each day's plan is a
/// distinct sub-collection.
class PlannerRepositoryImpl implements PlannerRepository {
  /// Creates a repository backed by the injected [firestore] client.
  ///
  /// The constructor receives Firestore directly because this repository has
  /// no abstract data-source layer — its sole job is mapping domain objects to
  /// Firestore documents. If a data-source abstraction is needed in the future
  /// it can be introduced without changing the [PlannerRepository] interface.
  PlannerRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  /// Returns the `users/{uid}/planner/{dateKey}/sessions` collection.
  CollectionReference<Map<String, dynamic>> _sessions(
    String uid,
    DateTime date,
  ) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('planner')
        .doc(_dateKey(date))
        .collection('sessions');
  }

  @override
  Future<List<PlannerSessionEntity>> getSessionsForDate(
    String uid,
    DateTime date,
  ) async {
    final snapshot = await _sessions(uid, date).get();
    return snapshot.docs
        .map((doc) => PlannerSessionModel.fromJson(doc.data()))
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  @override
  Future<void> saveSessions(
    String uid,
    List<PlannerSessionEntity> sessions,
  ) async {
    if (sessions.isEmpty) return;
    final date = sessions.first.startTime;
    final col = _sessions(uid, date);
    final batch = _firestore.batch();
    for (final session in sessions) {
      final model = PlannerSessionModel.fromEntity(session);
      batch.set(col.doc(model.id), model.toJson());
    }
    await batch.commit();
  }

  @override
  Future<void> markSessionCompleted(String uid, String sessionId) async {
    // We need the date to locate the document. Search today's plan only.
    final today = DateTime.now();
    await _sessions(uid, today).doc(sessionId).update({'completed': true});
  }

  @override
  Future<void> clearSessionsForDate(String uid, DateTime date) async {
    final snapshot = await _sessions(uid, date).get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Formats a [DateTime] as a `yyyy-MM-dd` document key.
  static String _dateKey(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
