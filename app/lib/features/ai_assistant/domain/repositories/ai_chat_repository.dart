import '../../domain/entities/chat_message_entity.dart';

abstract class AiChatRepository {
  Future<List<ChatMessageEntity>> getMessages(String userId);
  Future<void> saveMessage(String userId, ChatMessageEntity message);
}
