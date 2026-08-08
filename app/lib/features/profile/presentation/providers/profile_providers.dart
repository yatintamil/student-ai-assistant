import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/profile_remote_data_source.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';
import '../controllers/profile_controller.dart';
import '../states/profile_state.dart';

/// Provides the Firestore client used by the profile feature.
///
/// This is the profile feature's sole reference to [FirebaseFirestore.instance].
/// Downstream providers receive the injected client, allowing them to be
/// overridden in tests without accessing the Firebase singleton directly.
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provides remote profile persistence backed by Firestore.
///
/// The data source receives its [FirebaseFirestore] dependency from
/// [firebaseFirestoreProvider], keeping Firestore construction at the
/// composition boundary.
final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return FirebaseProfileRemoteDataSource(firestore);
});

/// Provides the domain [ProfileRepository] implementation.
///
/// The repository is constructed with the injected [ProfileRemoteDataSource]
/// and remains independent of the Firestore SDK.
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final remoteDataSource = ref.watch(profileRemoteDataSourceProvider);
  return ProfileRepositoryImpl(remoteDataSource);
});

/// Provides the [ProfileController] as the source of profile presentation
/// state.
///
/// The controller follows Riverpod 3's [Notifier] pattern and resolves the
/// repository itself inside [ProfileController.build].
final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileState>(ProfileController.new);
