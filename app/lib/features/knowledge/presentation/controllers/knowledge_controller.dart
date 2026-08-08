import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/knowledge_entity.dart';
import '../../domain/repositories/knowledge_repository.dart';
import '../providers/knowledge_providers.dart';
import '../states/knowledge_state.dart';

class KnowledgeController extends Notifier<KnowledgeState> {
  late KnowledgeRepository _repository;

  @override
  KnowledgeState build() {
    _repository = ref.read(knowledgeRepositoryProvider);
    return const KnowledgeState();
  }

  Future<void> loadNotes(String userId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final notes = await _repository.getKnowledgeNotes(userId);
      state = state.copyWith(notes: notes, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load notes: $e',
      );
    }
  }

  Future<void> saveNote(String userId, KnowledgeEntity note) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.saveKnowledgeNote(userId, note);
      await loadNotes(userId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to save note: $e',
      );
    }
  }

  Future<void> deleteNote(String userId, String noteId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.deleteKnowledgeNote(userId, noteId);
      await loadNotes(userId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to delete note: $e',
      );
    }
  }
}
