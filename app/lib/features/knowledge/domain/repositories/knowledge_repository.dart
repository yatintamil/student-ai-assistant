import '../entities/knowledge_entity.dart';

abstract class KnowledgeRepository {
  Future<List<KnowledgeEntity>> getKnowledgeNotes(String userId);
  Future<void> saveKnowledgeNote(String userId, KnowledgeEntity note);
  Future<void> deleteKnowledgeNote(String userId, String noteId);
}
