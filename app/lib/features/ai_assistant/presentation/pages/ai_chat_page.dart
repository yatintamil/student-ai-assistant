import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../../../core/config/gemini_config.dart';
import '../../../../core/services/life_context/life_context_providers.dart';
import '../providers/ai_chat_providers.dart';

class AiChatPage extends ConsumerStatefulWidget {
  const AiChatPage({super.key});

  @override
  ConsumerState<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends ConsumerState<AiChatPage> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = ref.read(authControllerProvider).user?.id;
      if (uid != null) {
        ref.read(aiChatControllerProvider.notifier).loadHistory(uid);
      }
    });
  }

  void _sendMessage([String? presetText]) {
    final text = presetText ?? _inputController.text;
    if (text.trim().isEmpty) return;

    _inputController.clear();
    final lifeContext = ref.read(lifeContextProvider);
    final uid = ref.read(authControllerProvider).user?.id;
    ref.read(aiChatControllerProvider.notifier).sendMessage(
          text,
          userId: uid,
          lifeContext: lifeContext.toPromptContext(),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(aiChatControllerProvider);
    final theme = Theme.of(context);

    final isGeminiConnected = GeminiConfig.isConfigured;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chief of Staff Assistant'),
      ),
      body: Column(
        children: [
          if (!isGeminiConnected)
            MaterialBanner(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              content: const Text(
                'Gemini API key is not connected. Launch with --dart-define=GEMINI_API_KEY=AIzaSy...',
                style: TextStyle(fontSize: 13),
              ),
              leading: const Icon(Icons.warning_amber_rounded, color: Colors.amber),
              backgroundColor: Colors.amber.withOpacity(0.15),
              actions: const [SizedBox.shrink()],
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: chatState.messages.length,
              itemBuilder: (context, index) {
                final message = chatState.messages[index];
                final isUser = message.sender == ChatSender.user;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: [
                          if (!isUser) ...[
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: theme.colorScheme.primaryContainer,
                              child: Icon(Icons.smart_toy_outlined, size: 18, color: theme.colorScheme.primary),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                message.text,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isUser
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                          if (isUser) ...[
                            const SizedBox(width: 8),
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: theme.colorScheme.secondaryContainer,
                              child: Icon(Icons.person, size: 18, color: theme.colorScheme.secondary),
                            ),
                          ],
                        ],
                      ),
                      if (message.suggestedActions.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: message.suggestedActions.map((action) {
                            return ActionChip(
                              label: Text(action, style: const TextStyle(fontSize: 11)),
                              onPressed: () => _sendMessage(action),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          if (chatState.isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Container(
            padding: const EdgeInsets.all(12),
            color: theme.colorScheme.surface,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: const InputDecoration(
                      hintText: 'Ask your Chief of Staff...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
