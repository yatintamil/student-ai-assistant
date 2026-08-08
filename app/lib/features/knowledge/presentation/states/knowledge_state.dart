import 'package:equatable/equatable.dart';

import '../../domain/entities/knowledge_entity.dart';

class KnowledgeState extends Equatable {
  const KnowledgeState({
    this.notes = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<KnowledgeEntity> notes;
  final bool isLoading;
  final String? errorMessage;

  KnowledgeState copyWith({
    List<KnowledgeEntity>? notes,
    bool? isLoading,
    String? errorMessage,
  }) {
    return KnowledgeState(
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [notes, isLoading, errorMessage];
}
