import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../providers/profile_providers.dart';
import '../states/profile_state.dart';

/// Owns profile presentation state and delegates profile operations to a
/// [ProfileRepository].
///
/// This Riverpod 3 [Notifier] resolves its repository through
/// [profileRepositoryProvider] in [build]. It does not access Firebase,
/// Firestore, UI classes, or navigation APIs.
class ProfileController extends Notifier<ProfileState> {
  late ProfileRepository _repository;
  int _loadVersion = 0;

  /// Initializes the controller with [ProfileState.initial] and resolves its
  /// repository dependency from the provider graph.
  @override
  ProfileState build() {
    _repository = ref.read(profileRepositoryProvider);
    return ProfileState.initial();
  }

  /// Loads the profile for [userId].
  ///
  /// A found profile transitions to [ProfileState.loaded]. A missing profile
  /// returns the controller to its initial state.
  Future<void> loadProfile(String userId) async {
    final loadVersion = ++_loadVersion;
    state = ProfileState.loading();
    try {
      final profile = await _repository.getProfile(userId);
      if (loadVersion != _loadVersion) {
        return;
      }
      state = profile == null ? ProfileState.initial() : ProfileState.loaded(profile);
    } on TimeoutException {
      // Firestore unreachable within timeout (e.g. emulator offline, UNAVAILABLE).
      // Treat as "no profile" so the app can proceed to onboarding instead of
      // spinning forever on the splash screen.
      if (loadVersion != _loadVersion) return;
      state = ProfileState.initial();
    } catch (error) {
      if (loadVersion != _loadVersion) {
        return;
      }
      state = ProfileState.error(_errorMessage(error));
    }
  }

  /// Clears the current profile when the authenticated user changes or signs out.
  ///
  /// Incrementing [_loadVersion] prevents an earlier in-flight profile request
  /// from restoring stale data after the state has been cleared.
  void clearProfile() {
    _loadVersion++;
    state = ProfileState.initial();
  }

  /// Saves [profile] and exposes it as the loaded profile on success.
  Future<void> saveProfile(ProfileEntity profile) async {
    state = ProfileState.loading();
    try {
      await _repository.saveProfile(profile);
      state = ProfileState.loaded(profile);
    } catch (error) {
      state = ProfileState.error(_errorMessage(error));
    }
  }

  /// Updates [profile] and exposes it as the loaded profile on success.
  Future<void> updateProfile(ProfileEntity profile) async {
    state = ProfileState.loading();
    try {
      await _repository.updateProfile(profile);
      state = ProfileState.loaded(profile);
    } catch (error) {
      state = ProfileState.error(_errorMessage(error));
    }
  }

  /// Deletes the profile for [userId] and resets the state on success.
  Future<void> deleteProfile(String userId) async {
    state = ProfileState.loading();
    try {
      await _repository.deleteProfile(userId);
      state = ProfileState.initial();
    } catch (error) {
      state = ProfileState.error(_errorMessage(error));
    }
  }

  /// Returns whether a profile exists for [userId].
  ///
  /// This query does not change the currently displayed profile state.
  Future<bool> profileExists(String userId) async {
    try {
      return await _repository.profileExists(userId);
    } catch (error) {
      state = ProfileState.error(_errorMessage(error));
      return false;
    }
  }

  /// Converts arbitrary failures into a safe presentation-layer message.
  String _errorMessage(Object error) {
    if (error is String) {
      return error;
    }
    return 'Something went wrong. Please try again.';
  }
}
