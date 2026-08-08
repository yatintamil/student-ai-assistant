import '../entities/profile_entity.dart';

/// Defines persistence operations for user profiles.
abstract interface class ProfileRepository {
  /// Retrieves the profile associated with [userId], if it exists.
  Future<ProfileEntity?> getProfile(String userId);

  /// Persists [profile] as a new user profile.
  Future<void> saveProfile(ProfileEntity profile);

  /// Updates the persisted data for [profile].
  Future<void> updateProfile(ProfileEntity profile);

  /// Returns whether a profile exists for [userId].
  Future<bool> profileExists(String userId);

  /// Deletes the profile associated with [userId].
  Future<void> deleteProfile(String userId);
}
