import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/journal_model.dart';

abstract class JournalRemoteDataSource {
  Future<List<JournalModel>> getJournalEntries(String userId);
  Future<void> saveJournalEntry(String userId, JournalModel journal);
  Future<void> deleteJournalEntry(String userId, String journalId);
}

class JournalRemoteDataSourceImpl implements JournalRemoteDataSource {
  JournalRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore.collection('users').doc(userId).collection('journals');
  }

  @override
  Future<List<JournalModel>> getJournalEntries(String userId) async {
    final snapshot = await _collection(userId)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs.map(JournalModel.fromFirestore).toList();
  }

  @override
  Future<void> saveJournalEntry(String userId, JournalModel journal) async {
    await _collection(userId).doc(journal.id).set(journal.toMap());
  }

  @override
  Future<void> deleteJournalEntry(String userId, String journalId) async {
    await _collection(userId).doc(journalId).delete();
  }
}
