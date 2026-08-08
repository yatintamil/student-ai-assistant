import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/profile_model.dart';

/// Defines remote persistence operations for user profiles.
abstract class ProfileRemoteDataSource {
  /// Retrieves the profile associated with [userId], if it exists.
  Future<ProfileModel?> getProfile(String userId);

  /// Persists [profile] as a user profile document.
  Future<void> saveProfile(ProfileModel profile);

  /// Updates the persisted data for [profile].
  Future<void> updateProfile(ProfileModel profile);

  /// Returns whether a profile exists for [userId].
  Future<bool> profileExists(String userId);

  /// Deletes the profile associated with [userId].
  Future<void> deleteProfile(String userId);
}

/// Firestore implementation of [ProfileRemoteDataSource].
class FirebaseProfileRemoteDataSource implements ProfileRemoteDataSource {
  /// Creates a Firestore-backed profile data source.
  FirebaseProfileRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _profiles =>
      _firestore.collection('users');

  @override
  Future<ProfileModel?> getProfile(String userId) async {
    // 1. Try to serve from local Firestore cache immediately (offline-safe).
    try {
      final cached = await _profiles
          .doc(userId)
          .get(const GetOptions(source: Source.cache));
      if (cached.exists) {
        final data = cached.data();
        if (data != null) return ProfileModel.fromJson(data);
      }
    } catch (_) {
      // Cache miss or not yet persisted — fall through to server fetch.
    }

    // 2. Fetch from server with a 10-second timeout so the app never hangs
    //    when Firestore is unreachable (UNAVAILABLE / no network).
    final snapshot = await _profiles
        .doc(userId)
        .get()
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () =>
              throw TimeoutException('Profile fetch timed out after 10 s'),
        );

    final data = snapshot.data();
    if (data == null) return null;
    return ProfileModel.fromJson(data);
  }

  @override
  Future<void> saveProfile(ProfileModel profile) {
    return _profiles.doc(profile.id).set(profile.toJson());
  }

  @override
  Future<void> updateProfile(ProfileModel profile) {
    return _profiles.doc(profile.id).update(profile.toJson());
  }

  @override
  Future<bool> profileExists(String userId) async {
    final snapshot = await _profiles.doc(userId).get();
    return snapshot.exists;
  }

  @override
  Future<void> deleteProfile(String userId) {
    return _profiles.doc(userId).delete();
  }
}
