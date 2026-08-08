import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message_model.dart';

abstract class AiChatRemoteDataSource {
  Future<List<ChatMessageModel>> getMessages(String userId);
  Future<void> saveMessage(String userId, ChatMessageModel message);
}

class AiChatRemoteDataSourceImpl implements AiChatRemoteDataSource {
  AiChatRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('conversations')
        .doc('default')
        .collection('messages');
  }

  @override
  Future<List<ChatMessageModel>> getMessages(String userId) async {
    final snapshot =
        await _collection(userId).orderBy('timestamp', descending: false).get();
    return snapshot.docs.map(ChatMessageModel.fromFirestore).toList();
  }

  @override
  Future<void> saveMessage(String userId, ChatMessageModel message) async {
    await _collection(userId).doc(message.id).set(message.toMap());
  }
}
