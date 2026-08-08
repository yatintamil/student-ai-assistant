import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/config/gemini_config.dart';
import '../../../../core/services/life_context/life_context_providers.dart';
import '../../../planner/presentation/providers/planner_providers.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/repositories/ai_chat_repository.dart';
import '../providers/ai_chat_providers.dart';
import '../states/ai_chat_state.dart';

class AiChatController extends Notifier<AiChatState> {
  GenerativeModel? _model;
  AiChatRepository? _repository;

  @override
  AiChatState build() {
    final apiKey = GeminiConfig.apiKey;
    if (apiKey.isNotEmpty) {
      _model = GenerativeModel(
        model: GeminiConfig.defaultModel,
        apiKey: apiKey,
      );
    }
    _repository = ref.read(aiChatRepositoryProvider);

    final initialGreeting = ChatMessageEntity(
      id: const Uuid().v4(),
      sender: ChatSender.assistant,
      text: 'Hello! I am your AI Chief of Staff. How can I help align your day with your long-term vision and goals?',
      timestamp: DateTime.now(),
      suggestedActions: const [
        'What should I do right now?',
        'Review my weekly goal progress',
        'Help me re-prioritize today\'s schedule',
      ],
    );
    return AiChatState(messages: [initialGreeting]);
  }

  Future<void> loadHistory(String userId) async {
    try {
      final savedMessages = await _repository?.getMessages(userId);
      if (savedMessages != null && savedMessages.isNotEmpty) {
        state = state.copyWith(messages: savedMessages);
      }
    } catch (_) {
      // Keep default state on offline/error
    }
  }

  Future<void> sendMessage(String text, {String? userId, String? lifeContext}) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessageEntity(
      id: const Uuid().v4(),
      sender: ChatSender.user,
      text: text.trim(),
      timestamp: DateTime.now(),
    );

    final updatedMessages = List<ChatMessageEntity>.from(state.messages)..add(userMsg);
    state = state.copyWith(messages: updatedMessages, isLoading: true, errorMessage: null);

    if (userId != null && userId.isNotEmpty) {
      _repository?.saveMessage(userId, userMsg);
    }

    // Detect if user wants to alter/update/replan their schedule
    final lowerText = text.toLowerCase();
    final isReplanRequest = lowerText.contains('re-prioritize') ||
        lowerText.contains('reprioritize') ||
        lowerText.contains('re-plan') ||
        lowerText.contains('replan') ||
        lowerText.contains('change my plan') ||
        lowerText.contains('update my plan') ||
        lowerText.contains('change schedule') ||
        lowerText.contains('update schedule') ||
        lowerText.contains('simplify plan') ||
        lowerText.contains('fit into');

    try {
      // If replanning is requested and userId is present, trigger planner controller update
      if (isReplanRequest && userId != null && userId.isNotEmpty) {
        final currentContext = ref.read(lifeContextProvider);
        if (lowerText.contains('simplify')) {
          await ref.read(plannerControllerProvider.notifier).simplifyPlanFromContext(
            uid: userId,
            lifeContext: currentContext,
          );
        } else {
          await ref.read(plannerControllerProvider.notifier).regeneratePlanFromContext(
            uid: userId,
            lifeContext: currentContext,
          );
        }
      }

      if (_model == null) {
        throw StateError(
          'Gemini API key not configured. '
          'Build with --dart-define=GEMINI_API_KEY=your_key',
        );
      }

      final prompt = '''
You are a personal Chief of Staff and AI Life Operating System assistant.
Your sole focus is to help the user achieve their long-term goals, maintain healthy habits, and optimize their daily decisions.

${lifeContext != null ? 'CURRENT LIFE CONTEXT:\n$lifeContext\n' : ''}

${isReplanRequest ? 'NOTE: You have automatically triggered a schedule re-plan for the user based on their context. In your response, confirm that their Today\'s Plan has been updated and explain how the new schedule aligns with their goals.' : ''}

USER QUESTION:
"$text"

Provide a direct, inspiring, and actionable response aligned with their goals. Keep responses structured, concise, and empowering.
''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      var assistantText = response.text ?? 'I apologize, I could not process that request.';

      if (isReplanRequest && !assistantText.contains("Today's Plan")) {
        assistantText += '\n\n✨ *I have updated your schedule for today! Check your Today\'s Plan tab to view your revised timeline.*';
      }

      final assistantMsg = ChatMessageEntity(
        id: const Uuid().v4(),
        sender: ChatSender.assistant,
        text: assistantText.trim(),
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: List<ChatMessageEntity>.from(state.messages)..add(assistantMsg),
        isLoading: false,
      );

      if (userId != null && userId.isNotEmpty) {
        _repository?.saveMessage(userId, assistantMsg);
      }
    } catch (e) {
      final errorStr = e.toString();
      final isRateLimit = errorStr.contains('429') ||
          errorStr.toLowerCase().contains('too many requests');
      final isApiKeyMissing = errorStr.contains('Gemini API key not configured');

      final String errorText;
      if (isApiKeyMissing) {
        errorText = 'Gemini API key is not connected.\n\n'
            'Please run the app with a valid Google AI Studio Gemini API key:\n'
            'flutter run --dart-define=GEMINI_API_KEY=AIzaSy...';
      } else if (isRateLimit) {
        errorText = 'Gemini API rate limit reached (429: Too Many Requests). Please wait a few seconds before trying again.';
      } else {
        errorText = 'Sorry, Gemini could not process the request: $e\n\n'
            'Please verify your GEMINI_API_KEY (starts with AIzaSy...) and network connection.';
      }

      final errorMsg = ChatMessageEntity(
        id: const Uuid().v4(),
        sender: ChatSender.assistant,
        text: errorText,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: List<ChatMessageEntity>.from(state.messages)..add(errorMsg),
        isLoading: false,
      );
    }
  }
}
