import 'package:equatable/equatable.dart';

/// Immutable domain representation of a student's profile.
class ProfileEntity extends Equatable {
  /// Creates a student's profile.
  const ProfileEntity({
    required this.id,
    required this.displayName,
    required this.email,
    this.photoUrl,
    required this.country,
    required this.timeZone,
    required this.collegeName,
    required this.degree,
    required this.semester,
    required this.sleepTime,
    required this.wakeUpTime,
    required this.preferredStudyStart,
    required this.preferredStudyEnd,
    required this.dailyStudyGoalMinutes,
    required this.onboardingCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Unique identifier of the student.
  final String id;

  /// Student's preferred name for display in the application.
  final String displayName;

  /// Student's email address.
  final String email;

  /// Optional URL of the student's profile photo.
  final String? photoUrl;

  /// Country where the student is located.
  final String country;

  /// IANA time-zone identifier used for the student's local schedule.
  final String timeZone;

  /// Name of the student's college or institution.
  final String collegeName;

  /// Degree program the student is pursuing.
  final String degree;

  /// Current semester of the student's degree program.
  final String semester;

  /// Student's preferred sleep time in a domain-defined time format.
  final String sleepTime;

  /// Student's preferred wake-up time in a domain-defined time format.
  final String wakeUpTime;

  /// Start of the student's preferred study period in a domain-defined time format.
  final String preferredStudyStart;

  /// End of the student's preferred study period in a domain-defined time format.
  final String preferredStudyEnd;

  /// Target number of minutes the student intends to study each day.
  final int dailyStudyGoalMinutes;

  /// Whether the student has completed application onboarding.
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
        collegeName,
        degree,
        semester,
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
