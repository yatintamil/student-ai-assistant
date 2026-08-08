import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/task_remote_data_source.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/task_repository.dart';
import '../controllers/task_controller.dart';
import '../states/task_state.dart';

/// Provides the [FirebaseFirestore] client used by the task feature.
///
/// This is the task feature's sole reference to [FirebaseFirestore.instance].
/// Downstream providers receive the injected client, allowing them to be
/// overridden in tests without accessing the Firebase singleton directly.
final taskFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provides remote task persistence backed by Firestore.
///
/// The data source receives its [FirebaseFirestore] dependency from
/// [taskFirestoreProvider], keeping Firestore construction at the composition
/// boundary.
final taskRemoteDataSourceProvider = Provider<TaskRemoteDataSource>((ref) {
  final firestore = ref.watch(taskFirestoreProvider);
  return FirebaseTaskRemoteDataSource(firestore);
});

/// Provides the domain [TaskRepository] implementation.
///
/// The repository is constructed with the injected [TaskRemoteDataSource]
/// and remains independent of the Firestore SDK.
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final remoteDataSource = ref.watch(taskRemoteDataSourceProvider);
  return TaskRepositoryImpl(remoteDataSource);
});

/// Provides the [TaskController] as the source of task presentation state.
///
/// The controller follows Riverpod 3's [Notifier] pattern and resolves the
/// repository itself inside [TaskController.build].
final taskControllerProvider =
    NotifierProvider<TaskController, TaskState>(TaskController.new);
