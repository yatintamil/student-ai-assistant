import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/knowledge_remote_data_source.dart';
import '../../data/repositories/knowledge_repository_impl.dart';
import '../../domain/repositories/knowledge_repository.dart';
import '../controllers/knowledge_controller.dart';
import '../states/knowledge_state.dart';

final knowledgeRemoteDataSourceProvider =
    Provider<KnowledgeRemoteDataSource>((ref) {
  return KnowledgeRemoteDataSourceImpl();
});

final knowledgeRepositoryProvider = Provider<KnowledgeRepository>((ref) {
  return KnowledgeRepositoryImpl(ref.watch(knowledgeRemoteDataSourceProvider));
});

final knowledgeControllerProvider =
    NotifierProvider<KnowledgeController, KnowledgeState>(KnowledgeController.new);
