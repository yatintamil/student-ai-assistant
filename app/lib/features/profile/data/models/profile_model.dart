import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/profile_entity.dart';

/// Firestore-backed representation of a user's profile.
class ProfileModel extends ProfileEntity {
  /// Creates an immutable [ProfileModel].
  const ProfileModel({
    required super.id,
    required super.displayName,
    required super.email,
    super.photoUrl,
    required super.country,
    required super.timeZone,
    required super.sleepTime,
    required super.wakeUpTime,
    required super.preferredStudyStart,
    required super.preferredStudyEnd,
    required super.dailyStudyGoalMinutes,
    required super.onboardingCompleted,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Creates a [ProfileModel] from Firestore document data.
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      country: json['country'] as String? ?? '',
      timeZone: json['timeZone'] as String? ?? '',
      sleepTime: json['sleepTime'] as String? ?? '',
      wakeUpTime: json['wakeUpTime'] as String? ?? '',
      preferredStudyStart: json['preferredStudyStart'] as String? ?? '',
      preferredStudyEnd: json['preferredStudyEnd'] as String? ?? '',
      dailyStudyGoalMinutes: json['dailyStudyGoalMinutes'] as int? ?? 0,
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      createdAt: _dateTimeFromFirestore(json['createdAt']),
      updatedAt: _dateTimeFromFirestore(json['updatedAt']),
    );
  }

  /// Converts this model to Firestore-compatible document data.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'country': country,
      'timeZone': timeZone,
      'sleepTime': sleepTime,
      'wakeUpTime': wakeUpTime,
      'preferredStudyStart': preferredStudyStart,
      'preferredStudyEnd': preferredStudyEnd,
      'dailyStudyGoalMinutes': dailyStudyGoalMinutes,
      'onboardingCompleted': onboardingCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static DateTime _dateTimeFromFirestore(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    throw ArgumentError.value(
      value,
      'value',
      'Expected a Firestore Timestamp or DateTime.',
    );
  }
}
