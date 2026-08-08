import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/journal_entity.dart';

class JournalModel {
  const JournalModel({
    required this.id,
    required this.date,
    required this.mood,
    required this.energyLevel,
    required this.wins,
    required this.lessonsLearned,
    required this.reflectionText,
    required this.createdAt,
  });

  factory JournalModel.fromEntity(JournalEntity entity) {
    return JournalModel(
      id: entity.id,
      date: entity.date,
      mood: entity.mood.name,
      energyLevel: entity.energyLevel,
      wins: entity.wins,
      lessonsLearned: entity.lessonsLearned,
      reflectionText: entity.reflectionText,
      createdAt: entity.createdAt,
    );
  }

  factory JournalModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return JournalModel(
      id: doc.id,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      mood: data['mood'] as String? ?? MoodLevel.good.name,
      energyLevel: data['energyLevel'] as int? ?? 7,
      wins: List<String>.from(data['wins'] as List<dynamic>? ?? []),
      lessonsLearned: List<String>.from(data['lessonsLearned'] as List<dynamic>? ?? []),
      reflectionText: data['reflectionText'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  final String id;
  final DateTime date;
  final String mood;
  final int energyLevel;
  final List<String> wins;
  final List<String> lessonsLearned;
  final String reflectionText;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'mood': mood,
      'energyLevel': energyLevel,
      'wins': wins,
      'lessonsLearned': lessonsLearned,
      'reflectionText': reflectionText,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  JournalEntity toEntity() {
    final parsedMood = MoodLevel.values.firstWhere(
      (e) => e.name == mood,
      orElse: () => MoodLevel.good,
    );

    return JournalEntity(
      id: id,
      date: date,
      mood: parsedMood,
      energyLevel: energyLevel,
      wins: wins,
      lessonsLearned: lessonsLearned,
      reflectionText: reflectionText,
      createdAt: createdAt,
    );
  }
}
