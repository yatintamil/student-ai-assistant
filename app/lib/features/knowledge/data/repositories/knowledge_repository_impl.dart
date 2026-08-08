import '../../domain/entities/knowledge_entity.dart';
import '../../domain/repositories/knowledge_repository.dart';
import '../datasources/knowledge_remote_data_source.dart';
import '../models/knowledge_model.dart';

class KnowledgeRepositoryImpl implements KnowledgeRepository {
  const KnowledgeRepositoryImpl(this._remoteDataSource);

  final KnowledgeRemoteDataSource _remoteDataSource;

  @override
  Future<List<KnowledgeEntity>> getKnowledgeNotes(String userId) async {
    final models = await _remoteDataSource.getKnowledgeNotes(userId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> saveKnowledgeNote(String userId, KnowledgeEntity note) async {
    final model = KnowledgeModel.fromEntity(note);
    await _remoteDataSource.saveKnowledgeNote(userId, model);
  }

  @override
  Future<void> deleteKnowledgeNote(String userId, String noteId) async {
    await _remoteDataSource.deleteKnowledgeNote(userId, noteId);
  }
}
