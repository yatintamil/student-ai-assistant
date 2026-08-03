import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../providers/auth_providers.dart';
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
///
/// ## Riverpod 3
///
/// This controller follows the official Riverpod 3 [Notifier] pattern: it has
/// a zero-argument constructor and resolves its dependencies inside [build]
/// via [Ref.read]. The [AuthRepository] is read from [authRepositoryProvider]
/// rather than being injected through the constructor, so the controller can
/// be exposed as a [NotifierProvider] by [authControllerProvider].
class AuthController extends Notifier<AuthState> {
  /// The auth data source, resolved from [authRepositoryProvider] during
  /// [build].
  ///
  /// It is read once during initialization so the controller delegates all
  /// authentication operations to the repository abstraction without ever
  /// touching Firebase or the data layer directly.
  late AuthRepository _repository;

  /// Initializes the controller with the initial [AuthState.initial] state
  /// and resolves the [AuthRepository] from the provider graph.
  ///
  /// [Ref.read] is used (rather than [Ref.watch]) because the repository is a
  /// stable singleton that never changes; reading it during [build] keeps the
  /// controller decoupled from the concrete repository implementation.
  @override
  AuthState build() {
    _repository = ref.read(authRepositoryProvider);
    return AuthState.initial();
  }

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
