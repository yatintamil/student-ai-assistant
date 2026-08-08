import 'package:flutter_test/flutter_test.dart';
import 'package:student_ai_assistant/features/goals/domain/entities/goal_entity.dart';

void main() {
  group('GoalEntity', () {
    test('supports value equality and copyWith', () {
      final now = DateTime.now();
      final goal1 = GoalEntity(
        id: '1',
        title: 'Learn Flutter & AI',
        description: 'Build a chief of staff app',
        level: GoalLevel.quarterly,
        category: GoalCategory.education,
        createdAt: now,
        updatedAt: now,
      );

      final goal2 = GoalEntity(
        id: '1',
        title: 'Learn Flutter & AI',
        description: 'Build a chief of staff app',
        level: GoalLevel.quarterly,
        category: GoalCategory.education,
        createdAt: now,
        updatedAt: now,
      );

      expect(goal1, equals(goal2));

      final updatedGoal = goal1.copyWith(isCompleted: true, progress: 1.0);
      expect(updatedGoal.isCompleted, isTrue);
      expect(updatedGoal.progress, equals(1.0));
      expect(updatedGoal.id, equals('1'));
    });
  });
}
