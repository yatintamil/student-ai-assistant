import '../datasources/ai_chat_remote_data_source.dart';
import '../models/chat_message_model.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/repositories/ai_chat_repository.dart';

class AiChatRepositoryImpl implements AiChatRepository {
  AiChatRepositoryImpl(this._remoteDataSource);

  final AiChatRemoteDataSource _remoteDataSource;

  @override
  Future<List<ChatMessageEntity>> getMessages(String userId) {
    return _remoteDataSource.getMessages(userId);
  }

  @override
  Future<void> saveMessage(String userId, ChatMessageEntity message) {
    return _remoteDataSource.saveMessage(
      userId,
      ChatMessageModel.fromEntity(message),
    );
  }
}
