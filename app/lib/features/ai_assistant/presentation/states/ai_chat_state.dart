import 'package:equatable/equatable.dart';

import '../../domain/entities/chat_message_entity.dart';

class AiChatState extends Equatable {
  const AiChatState({
    this.messages = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<ChatMessageEntity> messages;
  final bool isLoading;
  final String? errorMessage;

  AiChatState copyWith({
    List<ChatMessageEntity>? messages,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [messages, isLoading, errorMessage];
}
