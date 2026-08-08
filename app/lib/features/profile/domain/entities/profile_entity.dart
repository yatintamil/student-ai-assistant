import 'package:equatable/equatable.dart';

/// Immutable domain representation of a user's profile.
class ProfileEntity extends Equatable {
  /// Creates a user's profile.
  const ProfileEntity({
    required this.id,
    required this.displayName,
    required this.email,
    this.photoUrl,
    required this.country,
    required this.timeZone,
    required this.sleepTime,
    required this.wakeUpTime,
    required this.preferredStudyStart,
    required this.preferredStudyEnd,
    required this.dailyStudyGoalMinutes,
    required this.onboardingCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Unique identifier of the user.
  final String id;

  /// User's preferred name for display in the application.
  final String displayName;

  /// User's email address.
  final String email;

  /// Optional URL of the user's profile photo.
  final String? photoUrl;

  /// Country where the user is located.
  final String country;

  /// IANA time-zone identifier used for the user's local schedule.
  final String timeZone;

  /// User's preferred sleep time in a domain-defined time format.
  final String sleepTime;

  /// User's preferred wake-up time in a domain-defined time format.
  final String wakeUpTime;

  /// Start of the user's preferred work period in a domain-defined time format.
  final String preferredStudyStart;

  /// End of the user's preferred work period in a domain-defined time format.
  final String preferredStudyEnd;

  /// Target number of minutes the user intends to focus each day.
  final int dailyStudyGoalMinutes;

  /// Whether the user has completed application onboarding.
  final bool onboardingCompleted;

  /// Time at which the profile was created.
  final DateTime createdAt;

  /// Time at which the profile was most recently updated.
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        displayName,
        email,
        photoUrl,
        country,
        timeZone,
        sleepTime,
        wakeUpTime,
        preferredStudyStart,
        preferredStudyEnd,
        dailyStudyGoalMinutes,
        onboardingCompleted,
        createdAt,
        updatedAt,
      ];
}
