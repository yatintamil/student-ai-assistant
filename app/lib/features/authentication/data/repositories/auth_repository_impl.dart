import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/services/auth/auth_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

/// Concrete data-layer implementation of [AuthRepository].
///
/// Bridges the core [AuthService] abstraction with the domain layer by:
///
/// * Delegating every authentication operation to the injected [AuthService],
///   keeping Firebase Authentication and Google Sign-In out of this class.
/// * Translating Firebase [User] instances (exposed by [AuthService]) into
///   domain [UserEntity] objects via [UserModel.fromFirebaseUser].
///
/// ## Clean Architecture
///
/// The data layer is the only layer that may depend on Firebase SDK types.
/// Consumers above this repository access authentication exclusively through
/// the [AuthRepository] interface, which exposes only domain entities.
class AuthRepositoryImpl implements AuthRepository {
  /// Creates an [AuthRepositoryImpl] with the given [authService].
  ///
  /// The [AuthService] is constructor-injected so this repository can be
  /// tested with a fake or mocked service and never touches Firebase
  /// directly.
  AuthRepositoryImpl(this._authService);

  /// The core authentication service used for all authentication operations.
  ///
  /// This is the only dependency of the repository and the sole access point
  /// to Firebase Authentication. No Firebase or Google SDK is referenced
  /// anywhere else in this class.
  final AuthService _authService;

  /// Returns the currently authenticated user, or `null` when signed out.
  ///
  /// Delegates to [AuthService.currentUser] and converts the returned
  /// Firebase [User] into a [UserEntity] with [UserModel.fromFirebaseUser].
  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = _authService.currentUser;
    if (user == null) {
      return null;
    }
    return UserModel.fromFirebaseUser(user);
  }

  /// Signs in with Google and returns the authenticated [UserEntity].
  ///
  /// Delegates the sign-in flow to [AuthService.signInWithGoogle], then maps
  /// the resulting [UserCredential] into a domain entity.
  @override
  Future<UserEntity> signInWithGoogle() async {
    final credential = await _authService.signInWithGoogle();
    return _mapCredentialToEntity(credential);
  }

  /// Signs in with email and password and returns the authenticated
  /// [UserEntity].
  ///
  /// Delegates the sign-in flow to [AuthService.signInWithEmail], then maps
  /// the resulting [UserCredential] into a domain entity.
  @override
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _authService.signInWithEmail(
      email: email,
      password: password,
    );
    return _mapCredentialToEntity(credential);
  }

  /// Registers a new account and returns the authenticated [UserEntity].
  ///
  /// Delegates account creation to [AuthService.registerWithEmail], then maps
  /// the resulting [UserCredential] into a domain entity.
  @override
  Future<UserEntity> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _authService.registerWithEmail(
      name: name,
      email: email,
      password: password,
    );
    return _mapCredentialToEntity(credential);
  }

  /// Sends a password reset email to [email].
  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _authService.sendPasswordResetEmail(email: email);
  }

  /// Signs the current user out of the application.
  ///
  /// Delegates directly to [AuthService.signOut], which clears both the
  /// underlying Google and Firebase sessions.
  @override
  Future<void> signOut() => _authService.signOut();

  /// Maps a Firebase [UserCredential] into a domain [UserEntity].
  ///
  /// Every sign-in flow supported by this repository is expected to return a
  /// credential carrying a non-null [User]. If that invariant is ever
  /// violated, the credential cannot be converted into a [UserEntity] and the
  /// operation fails defensively with a [FirebaseAuthException].
  ///
  /// TODO(authentication): Replace the [FirebaseAuthException] with a
  /// project-specific `AuthException` once the exception layer is
  /// implemented.
  UserEntity _mapCredentialToEntity(UserCredential credential) {
    final User? user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'credential-without-user',
        message: 'Authentication completed without an attached user.',
      );
    }
    return UserModel.fromFirebaseUser(user);
  }
}
