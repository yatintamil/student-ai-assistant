import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/ai_chat_remote_data_source.dart';
import '../../data/repositories/ai_chat_repository_impl.dart';
import '../../domain/repositories/ai_chat_repository.dart';
import '../controllers/ai_chat_controller.dart';
import '../states/ai_chat_state.dart';

final aiChatRemoteDataSourceProvider = Provider<AiChatRemoteDataSource>((ref) {
  return AiChatRemoteDataSourceImpl();
});

final aiChatRepositoryProvider = Provider<AiChatRepository>((ref) {
  return AiChatRepositoryImpl(ref.watch(aiChatRemoteDataSourceProvider));
});

final aiChatControllerProvider =
    NotifierProvider<AiChatController, AiChatState>(AiChatController.new);
