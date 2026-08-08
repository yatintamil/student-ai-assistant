import 'package:equatable/equatable.dart';

/// How often a habit should be performed.
enum HabitFrequency {
  /// The habit is performed every day.
  daily,

  /// The habit is performed on specific days of the week.
  weekly,
}

/// Immutable domain representation of a recurring habit.
class HabitEntity extends Equatable {
  /// Creates a [HabitEntity].
  const HabitEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.frequency,
    required this.targetDays,
    required this.currentStreak,
    required this.longestStreak,
    required this.completedDates,
    required this.color,
    required this.iconName,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Unique identifier of the habit.
  final String id;

  /// Short title describing the habit.
  final String title;

  /// Optional longer description of the habit.
  final String description;

  /// How often the habit should be performed.
  final HabitFrequency frequency;

  /// For weekly habits, the ISO weekday numbers (1 = Monday … 7 = Sunday)
  /// on which the habit is scheduled. Empty for daily habits.
  final List<int> targetDays;

  /// Number of consecutive days the habit has been completed up to today.
  final int currentStreak;

  /// The longest streak this habit has ever achieved.
  final int longestStreak;

  /// The set of calendar dates (UTC midnight) on which this habit was
  /// completed. Used to compute streaks and today's completion status.
  final List<DateTime> completedDates;

  /// A hex colour string (e.g. `'#2563EB'`) used to tint the habit in the UI.
  final String color;

  /// The name of a Material icon used to represent the habit.
  final String iconName;

  /// The time at which the habit was created.
  final DateTime createdAt;

  /// The time at which the habit was most recently updated.
  final DateTime updatedAt;

  /// Whether the habit has been completed today (UTC).
  bool get isCompletedToday {
    final today = _utcMidnight(DateTime.now());
    return completedDates.any((d) => _utcMidnight(d) == today);
  }

  static DateTime _utcMidnight(DateTime dt) =>
      DateTime.utc(dt.year, dt.month, dt.day);

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        frequency,
        targetDays,
        currentStreak,
        longestStreak,
        completedDates,
        color,
        iconName,
        createdAt,
        updatedAt,
      ];
}
