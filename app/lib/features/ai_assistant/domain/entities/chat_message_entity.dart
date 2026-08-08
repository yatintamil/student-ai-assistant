import 'package:equatable/equatable.dart';

enum ChatSender { user, assistant }

class ChatMessageEntity extends Equatable {
  const ChatMessageEntity({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.suggestedActions = const [],
  });

  final String id;
  final ChatSender sender;
  final String text;
  final DateTime timestamp;
  final List<String> suggestedActions;

  @override
  List<Object?> get props => [id, sender, text, timestamp, suggestedActions];
}
