import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/habit_remote_data_source.dart';
import '../../data/repositories/habit_repository_impl.dart';
import '../../domain/repositories/habit_repository.dart';
import '../controllers/habit_controller.dart';
import '../states/habit_state.dart';

/// Provides the [FirebaseFirestore] client used by the habit feature.
///
/// This is the habit feature's sole reference to [FirebaseFirestore.instance].
final habitFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provides remote habit persistence backed by Firestore.
final habitRemoteDataSourceProvider = Provider<HabitRemoteDataSource>((ref) {
  final firestore = ref.watch(habitFirestoreProvider);
  return FirebaseHabitRemoteDataSource(firestore);
});

/// Provides the domain [HabitRepository] implementation.
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final remoteDataSource = ref.watch(habitRemoteDataSourceProvider);
  return HabitRepositoryImpl(remoteDataSource);
});

/// Provides the [HabitController] as the source of habit presentation state.
final habitControllerProvider =
    NotifierProvider<HabitController, HabitState>(HabitController.new);
