import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/journal_remote_data_source.dart';
import '../../data/repositories/journal_repository_impl.dart';
import '../../domain/repositories/journal_repository.dart';
import '../controllers/journal_controller.dart';
import '../states/journal_state.dart';

final journalRemoteDataSourceProvider = Provider<JournalRemoteDataSource>((ref) {
  return JournalRemoteDataSourceImpl();
});

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return JournalRepositoryImpl(ref.watch(journalRemoteDataSourceProvider));
});

final journalControllerProvider =
    NotifierProvider<JournalController, JournalState>(JournalController.new);
