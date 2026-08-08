import 'package:flutter_test/flutter_test.dart';
import 'package:student_ai_assistant/features/journal/domain/entities/journal_entity.dart';

void main() {
  group('JournalEntity', () {
    test('supports value equality and copyWith', () {
      final now = DateTime.now();
      final journal1 = JournalEntity(
        id: 'j1',
        date: now,
        mood: MoodLevel.great,
        energyLevel: 9,
        reflectionText: 'Great day, completed core refactoring',
        createdAt: now,
      );

      final journal2 = JournalEntity(
        id: 'j1',
        date: now,
        mood: MoodLevel.great,
        energyLevel: 9,
        reflectionText: 'Great day, completed core refactoring',
        createdAt: now,
      );

      expect(journal1, equals(journal2));

      final updated = journal1.copyWith(energyLevel: 10);
      expect(updated.energyLevel, equals(10));
      expect(updated.id, equals('j1'));
    });
  });
}
