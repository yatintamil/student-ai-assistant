import '../../domain/entities/user_entity.dart';

/// An immutable snapshot of the authentication state.
///
/// Represents everything the presentation layer needs to know about
/// authentication at a given moment:
///
/// * The signed-in [user], or `null` when signed out.
/// * Whether an authentication operation is currently in progress ([isLoading]).
/// * An optional [errorMessage] describing the most recent failure.
///
/// Values are immutable. Every transition produces a new instance through a
/// named factory constructor or [copyWith], which makes state changes
/// predictable and safe for Riverpod to expose to the UI.
class AuthState {
  /// Creates an [AuthState] with the given values.
  ///
  /// This constructor is intentionally private. Callers should use the named
  /// factory constructors ([AuthState.initial], [AuthState.authenticated],
  /// [AuthState.loading], [AuthState.unauthenticated], or [AuthState.failure])
  /// to describe a concrete state, or [copyWith] to derive a new one.
  const AuthState._({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  /// Creates the initial authentication state.
  ///
  /// No user is signed in, no operation is running, and no error has been
  /// recorded. Use this before any authentication operation has begun.
  factory AuthState.initial() => const AuthState._();

  /// Creates an authenticated state for [user].
  ///
  /// Use this when a user has signed in successfully.
  factory AuthState.authenticated(UserEntity user) =>
      AuthState._(user: user);

  /// Creates a loading state.
  ///
  /// Use this while an authentication operation (sign-in, registration, or
  /// sign-out) is in progress.
  factory AuthState.loading() => const AuthState._(isLoading: true);

  /// Creates an unauthenticated state.
  ///
  /// Use this when no user is signed in, such as after sign-out or when the
  /// app starts without a saved session.
  factory AuthState.unauthenticated() => const AuthState._();

  /// Creates a failure state carrying [message].
  ///
  /// Use this when an authentication operation fails. The previous [user] is
  /// intentionally dropped so the UI does not keep showing a stale,
  /// authenticated screen after a failure.
  factory AuthState.failure(String message) =>
      AuthState._(errorMessage: message);

  /// The currently signed-in user, or `null` when signed out.
  final UserEntity? user;

  /// Whether an authentication operation is currently in progress.
  final bool isLoading;

  /// A message describing the latest authentication failure, if any.
  final String? errorMessage;

  /// Returns a copy of this state with the given fields replaced.
  ///
  /// Fields that are not provided keep their current value.
  AuthState copyWith({
    UserEntity? user,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState._(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AuthState &&
            other.user == user &&
            other.isLoading == isLoading &&
            other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hash(user, isLoading, errorMessage);
}
