import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/journal_entity.dart';
import '../../domain/repositories/journal_repository.dart';
import '../providers/journal_providers.dart';
import '../states/journal_state.dart';

class JournalController extends Notifier<JournalState> {
  late JournalRepository _repository;

  @override
  JournalState build() {
    _repository = ref.read(journalRepositoryProvider);
    return const JournalState();
  }

  Future<void> loadJournalEntries(String userId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final entries = await _repository.getJournalEntries(userId);
      state = state.copyWith(entries: entries, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load journal entries: $e',
      );
    }
  }

  Future<void> saveJournalEntry(String userId, JournalEntity journal) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.saveJournalEntry(userId, journal);
      await loadJournalEntries(userId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to save journal entry: $e',
      );
    }
  }

  Future<void> deleteJournalEntry(String userId, String journalId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.deleteJournalEntry(userId, journalId);
      await loadJournalEntries(userId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to delete journal entry: $e',
      );
    }
  }
}
