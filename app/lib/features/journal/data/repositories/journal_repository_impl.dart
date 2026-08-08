import '../../domain/entities/journal_entity.dart';
import '../../domain/repositories/journal_repository.dart';
import '../datasources/journal_remote_data_source.dart';
import '../models/journal_model.dart';

class JournalRepositoryImpl implements JournalRepository {
  const JournalRepositoryImpl(this._remoteDataSource);

  final JournalRemoteDataSource _remoteDataSource;

  @override
  Future<List<JournalEntity>> getJournalEntries(String userId) async {
    final models = await _remoteDataSource.getJournalEntries(userId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> saveJournalEntry(String userId, JournalEntity journal) async {
    final model = JournalModel.fromEntity(journal);
    await _remoteDataSource.saveJournalEntry(userId, model);
  }

  @override
  Future<void> deleteJournalEntry(String userId, String journalId) async {
    await _remoteDataSource.deleteJournalEntry(userId, journalId);
  }
}
