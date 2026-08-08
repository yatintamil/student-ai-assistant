import 'package:equatable/equatable.dart';

import '../../domain/entities/journal_entity.dart';

class JournalState extends Equatable {
  const JournalState({
    this.entries = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<JournalEntity> entries;
  final bool isLoading;
  final String? errorMessage;

  JournalState copyWith({
    List<JournalEntity>? entries,
    bool? isLoading,
    String? errorMessage,
  }) {
    return JournalState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [entries, isLoading, errorMessage];
}
