import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/habit_entity.dart';

/// Firestore-backed representation of a recurring habit.
class HabitModel extends HabitEntity {
  /// Creates an immutable [HabitModel].
  const HabitModel({
    required super.id,
    required super.title,
    required super.description,
    required super.frequency,
    required super.targetDays,
    required super.currentStreak,
    required super.longestStreak,
    required super.completedDates,
    required super.color,
    required super.iconName,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Creates a [HabitModel] from Firestore document data.
  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      frequency: _frequencyFromString(json['frequency'] as String?),
      targetDays: (json['targetDays'] as List<dynamic>? ?? <dynamic>[])
          .map((e) => (e as num).toInt())
          .toList(),
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      completedDates: (json['completedDates'] as List<dynamic>? ?? <dynamic>[])
          .map(_dateTimeFromFirestore)
          .toList(),
      color: json['color'] as String? ?? '#2563EB',
      iconName: json['iconName'] as String? ?? 'loop',
      createdAt: _dateTimeFromFirestore(json['createdAt']),
      updatedAt: _dateTimeFromFirestore(json['updatedAt']),
    );
  }

  /// Converts this model to Firestore-compatible document data.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'frequency': frequency.name,
      'targetDays': targetDays,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'completedDates':
          completedDates.map(Timestamp.fromDate).toList(),
      'color': color,
      'iconName': iconName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static DateTime _dateTimeFromFirestore(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    throw ArgumentError.value(
      value,
      'value',
      'Expected a Firestore Timestamp or DateTime.',
    );
  }

  static HabitFrequency _frequencyFromString(String? value) {
    return HabitFrequency.values.firstWhere(
      (e) => e.name == value,
      orElse: () => HabitFrequency.daily,
    );
  }
}
