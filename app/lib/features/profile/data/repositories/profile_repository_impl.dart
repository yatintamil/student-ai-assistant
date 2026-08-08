import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/profile_model.dart';

/// Data-layer implementation of [ProfileRepository].
///
/// Converts between domain [ProfileEntity] objects and data [ProfileModel]
/// objects, while delegating all persistence to [ProfileRemoteDataSource].
class ProfileRepositoryImpl implements ProfileRepository {
  /// Creates a repository backed by the injected [remoteDataSource].
  ///
  /// The repository does not access Firestore directly, which keeps it
  /// independently testable with a fake or mocked data source.
  ProfileRepositoryImpl(this._remoteDataSource);

  final ProfileRemoteDataSource _remoteDataSource;

  /// Retrieves and maps the profile associated with [userId], if it exists.
  @override
  Future<ProfileEntity?> getProfile(String userId) async {
    final model = await _remoteDataSource.getProfile(userId);
    return model == null ? null : _toEntity(model);
  }

  /// Maps [profile] to a model and persists it through the data source.
  @override
  Future<void> saveProfile(ProfileEntity profile) {
    return _remoteDataSource.saveProfile(_toModel(profile));
  }

  /// Maps [profile] to a model and updates it through the data source.
  @override
  Future<void> updateProfile(ProfileEntity profile) {
    return _remoteDataSource.updateProfile(_toModel(profile));
  }

  /// Returns whether the data source contains a profile for [userId].
  @override
  Future<bool> profileExists(String userId) {
    return _remoteDataSource.profileExists(userId);
  }

  /// Deletes the profile associated with [userId] through the data source.
  @override
  Future<void> deleteProfile(String userId) {
    return _remoteDataSource.deleteProfile(userId);
  }

  /// Converts a data-layer [ProfileModel] to a domain [ProfileEntity].
  ProfileEntity _toEntity(ProfileModel profile) {
    return ProfileEntity(
      id: profile.id,
      displayName: profile.displayName,
      email: profile.email,
      photoUrl: profile.photoUrl,
      country: profile.country,
      timeZone: profile.timeZone,
      sleepTime: profile.sleepTime,
      wakeUpTime: profile.wakeUpTime,
      preferredStudyStart: profile.preferredStudyStart,
      preferredStudyEnd: profile.preferredStudyEnd,
      dailyStudyGoalMinutes: profile.dailyStudyGoalMinutes,
      onboardingCompleted: profile.onboardingCompleted,
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
    );
  }

  /// Converts a domain [ProfileEntity] to a data-layer [ProfileModel].
  ProfileModel _toModel(ProfileEntity profile) {
    return ProfileModel(
      id: profile.id,
      displayName: profile.displayName,
      email: profile.email,
      photoUrl: profile.photoUrl,
      country: profile.country,
      timeZone: profile.timeZone,
      sleepTime: profile.sleepTime,
      wakeUpTime: profile.wakeUpTime,
      preferredStudyStart: profile.preferredStudyStart,
      preferredStudyEnd: profile.preferredStudyEnd,
      dailyStudyGoalMinutes: profile.dailyStudyGoalMinutes,
      onboardingCompleted: profile.onboardingCompleted,
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
    );
  }
}
