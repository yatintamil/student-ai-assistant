import '../../domain/entities/profile_entity.dart';

/// An immutable snapshot of the profile feature state.
///
/// A state contains the currently loaded [profile], the status of an active
/// repository operation, and an optional message for the most recent failure.
class ProfileState {
  /// Creates a [ProfileState] with the given values.
  const ProfileState._({
    this.profile,
    this.isLoading = false,
    this.errorMessage,
  });

  /// Creates the initial state with no loaded profile or error.
  factory ProfileState.initial() => const ProfileState._();

  /// Creates a state representing an active profile operation.
  factory ProfileState.loading() => const ProfileState._(isLoading: true);

  /// Creates a state containing the successfully loaded [profile].
  factory ProfileState.loaded(ProfileEntity profile) =>
      ProfileState._(profile: profile);

  /// Creates a failure state containing [message].
  factory ProfileState.error(String message) =>
      ProfileState._(errorMessage: message);

  /// The loaded user profile, if one is available.
  final ProfileEntity? profile;

  /// Whether a profile operation is currently in progress.
  final bool isLoading;

  /// A message describing the latest profile operation failure, if any.
  final String? errorMessage;

  /// Returns a copy of this state with the supplied fields replaced.
  ///
  /// Fields not supplied retain their existing values.
  ProfileState copyWith({
    ProfileEntity? profile,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProfileState._(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ProfileState &&
            other.profile == profile &&
            other.isLoading == isLoading &&
            other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hash(profile, isLoading, errorMessage);
}
