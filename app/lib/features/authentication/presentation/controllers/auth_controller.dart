import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../states/auth_state.dart';

/// The single source of truth for authentication state.
///
/// This controller wraps the [AuthRepository] and exposes the current
/// [AuthState] to the presentation layer. It owns the state lifecycle for
/// every authentication operation (sign-in, registration, sign-out, and
/// session restore) and is the only place that translates repository results
/// into [AuthState] transitions.
///
/// It intentionally depends only on [AuthRepository] and [AuthState]. It never
/// touches Firebase, Firestore, UI classes, or performs navigation, keeping
/// the presentation layer decoupled from the underlying infrastructure.
class AuthController extends Notifier<AuthState> {
  /// Creates an [AuthController] that delegates authentication operations to
  /// the provided [repository].
  ///
  /// [repository] is the auth data source. It is injected rather than created
  /// internally so the controller can be tested with a fake repository and
  /// stays independent of the concrete implementation.
  AuthController(this._repository);

  final AuthRepository _repository;

  @override
  AuthState build() => AuthState.initial();

  /// Signs the user in with their Google account.
  ///
  /// Sets the state to [AuthState.loading] while the operation is in progress.
  /// On success, the state becomes [AuthState.authenticated] with the returned
  /// [UserEntity]. On failure, the state becomes [AuthState.failure] carrying a
  /// human-readable message. Exceptions are caught here and never exposed to
  /// the UI.
  Future<void> signInWithGoogle() async {
    state = AuthState.loading();
    try {
      final user = await _repository.signInWithGoogle();
      state = AuthState.authenticated(user);
    } catch (error) {
      state = AuthState.failure(_errorMessage(error));
    }
  }

  /// Signs the user in with an email address and password.
  ///
  /// Sets the state to [AuthState.loading] while the operation is in progress.
  /// On success, the state becomes [AuthState.authenticated] with the returned
  /// [UserEntity]. On failure, the state becomes [AuthState.failure] carrying a
  /// human-readable message. Exceptions are caught here and never exposed to
  /// the UI.
  Future<void> signInWithEmail(String email, String password) async {
    state = AuthState.loading();
    try {
      final user = await _repository.signInWithEmail(
        email: email,
        password: password,
      );
      state = AuthState.authenticated(user);
    } catch (error) {
      state = AuthState.failure(_errorMessage(error));
    }
  }

  /// Registers a new user with the given [name], [email], and [password].
  ///
  /// Sets the state to [AuthState.loading] while the operation is in progress.
  /// On success, the state becomes [AuthState.authenticated] with the returned
  /// [UserEntity]. On failure, the state becomes [AuthState.failure] carrying a
  /// human-readable message. Exceptions are caught here and never exposed to
  /// the UI.
  Future<void> register(String name, String email, String password) async {
    state = AuthState.loading();
    try {
      final user = await _repository.registerWithEmail(
        name: name,
        email: email,
        password: password,
      );
      state = AuthState.authenticated(user);
    } catch (error) {
      state = AuthState.failure(_errorMessage(error));
    }
  }

  /// Signs the current user out.
  ///
  /// Sets the state to [AuthState.loading] while the operation is in progress.
  /// On success, the state becomes [AuthState.unauthenticated]. On failure,
  /// the state becomes [AuthState.failure] carrying a human-readable message.
  /// Exceptions are caught here and never exposed to the UI.
  Future<void> signOut() async {
    state = AuthState.loading();
    try {
      await _repository.signOut();
      state = AuthState.unauthenticated();
    } catch (error) {
      state = AuthState.failure(_errorMessage(error));
    }
  }

  /// Restores the currently signed-in user, typically at app startup.
  ///
  /// Sets the state to [AuthState.loading] while the operation is in progress.
  /// If a user is signed in, the state becomes [AuthState.authenticated]. If
  /// no user is signed in, the state becomes [AuthState.unauthenticated]. On
  /// failure, the state becomes [AuthState.failure] carrying a human-readable
  /// message. Exceptions are caught here and never exposed to the UI.
  Future<void> loadCurrentUser() async {
    state = AuthState.loading();
    try {
      final user = await _repository.getCurrentUser();
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = AuthState.unauthenticated();
      }
    } catch (error) {
      state = AuthState.failure(_errorMessage(error));
    }
  }

  /// Converts an arbitrary exception into a safe, human-readable message.
  ///
  /// This prevents raw exception details from leaking to the UI. A generic
  /// message is returned when the error is not a [String] so callers always
  /// receive something meaningful.
  String _errorMessage(Object error) {
    if (error is String) {
      return error;
    }
    return 'Something went wrong. Please try again.';
  }
}
