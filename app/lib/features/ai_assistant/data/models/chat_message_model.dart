import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_message_entity.dart';

class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.id,
    required super.sender,
    required super.text,
    required super.timestamp,
    super.suggestedActions,
  });

  factory ChatMessageModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};
    return ChatMessageModel(
      id: snapshot.id,
      sender: (data['sender'] as String? ?? 'assistant') == 'user'
          ? ChatSender.user
          : ChatSender.assistant,
      text: data['text'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      suggestedActions: (data['suggestedActions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  factory ChatMessageModel.fromEntity(ChatMessageEntity entity) {
    return ChatMessageModel(
      id: entity.id,
      sender: entity.sender,
      text: entity.text,
      timestamp: entity.timestamp,
      suggestedActions: entity.suggestedActions,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender': sender.name,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'suggestedActions': suggestedActions,
    };
  }
}
