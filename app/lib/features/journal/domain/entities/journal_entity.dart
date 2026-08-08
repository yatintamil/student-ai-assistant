import 'package:equatable/equatable.dart';

enum MoodLevel {
  great,
  good,
  okay,
  low,
  bad,
}

/// Domain entity representing a daily reflection / journal entry.
class JournalEntity extends Equatable {
  const JournalEntity({
    required this.id,
    required this.date,
    required this.mood,
    required this.energyLevel,
    this.wins = const [],
    this.lessonsLearned = const [],
    required this.reflectionText,
    required this.createdAt,
  });

  final String id;
  final DateTime date;
  final MoodLevel mood;

  /// Self-reported energy level from 1 (lowest) to 10 (highest).
  final int energyLevel;

  final List<String> wins;
  final List<String> lessonsLearned;
  final String reflectionText;
  final DateTime createdAt;

  JournalEntity copyWith({
    String? id,
    DateTime? date,
    MoodLevel? mood,
    int? energyLevel,
    List<String>? wins,
    List<String>? lessonsLearned,
    String? reflectionText,
    DateTime? createdAt,
  }) {
    return JournalEntity(
      id: id ?? this.id,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      energyLevel: energyLevel ?? this.energyLevel,
      wins: wins ?? this.wins,
      lessonsLearned: lessonsLearned ?? this.lessonsLearned,
      reflectionText: reflectionText ?? this.reflectionText,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        date,
        mood,
        energyLevel,
        wins,
        lessonsLearned,
        reflectionText,
        createdAt,
      ];
}
