import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/knowledge_model.dart';

abstract class KnowledgeRemoteDataSource {
  Future<List<KnowledgeModel>> getKnowledgeNotes(String userId);
  Future<void> saveKnowledgeNote(String userId, KnowledgeModel note);
  Future<void> deleteKnowledgeNote(String userId, String noteId);
}

class KnowledgeRemoteDataSourceImpl implements KnowledgeRemoteDataSource {
  KnowledgeRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore.collection('users').doc(userId).collection('notes');
  }

  @override
  Future<List<KnowledgeModel>> getKnowledgeNotes(String userId) async {
    final snapshot = await _collection(userId)
        .orderBy('updatedAt', descending: true)
        .get();
    return snapshot.docs.map(KnowledgeModel.fromFirestore).toList();
  }

  @override
  Future<void> saveKnowledgeNote(String userId, KnowledgeModel note) async {
    await _collection(userId).doc(note.id).set(note.toMap());
  }

  @override
  Future<void> deleteKnowledgeNote(String userId, String noteId) async {
    await _collection(userId).doc(noteId).delete();
  }
}
