import '../entities/journal_entity.dart';

abstract class JournalRepository {
  Future<List<JournalEntity>> getJournalEntries(String userId);
  Future<void> saveJournalEntry(String userId, JournalEntity journal);
  Future<void> deleteJournalEntry(String userId, String journalId);
}
