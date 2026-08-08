import 'package:flutter_test/flutter_test.dart';
import 'package:student_ai_assistant/core/services/life_context/life_context.dart';
import 'package:student_ai_assistant/features/journal/domain/entities/journal_entity.dart';
import 'package:student_ai_assistant/features/planner/domain/entities/planner_context.dart';
import 'package:student_ai_assistant/features/planner/domain/entities/planner_session_entity.dart';
import 'package:student_ai_assistant/features/profile/domain/entities/profile_entity.dart';
import 'package:student_ai_assistant/features/tasks/domain/entities/task_entity.dart';

void main() {
  group('LifeContext Unit Tests', () {
    test('inferredEnergy defaults to medium when journal is null', () {
      const context = LifeContext();
      expect(context.inferredEnergy, EnergyLevel.medium);
    });

    test('inferredEnergy infers low energy for level <= 3', () {
      final context = LifeContext(
        latestJournal: JournalEntity(
          id: '1',
          date: DateTime.now(),
          mood: MoodLevel.low,
          energyLevel: 2,
          wins: const [],
          lessonsLearned: const [],
          reflectionText: '',
          createdAt: DateTime.now(),
        ),
      );
      expect(context.inferredEnergy, EnergyLevel.low);
    });

    test('inferredEnergy infers high energy for level >= 8', () {
      final context = LifeContext(
        latestJournal: JournalEntity(
          id: '1',
          date: DateTime.now(),
          mood: MoodLevel.great,
          energyLevel: 9,
          wins: const [],
          lessonsLearned: const [],
          reflectionText: '',
          createdAt: DateTime.now(),
        ),
      );
      expect(context.inferredEnergy, EnergyLevel.high);
    });

    test('topRecommendation prioritizes current non-completed session', () {
      final now = DateTime.now();
      final session = PlannerSessionEntity(
        id: 's1',
        title: 'Deep Work Session',
        startTime: now.subtract(const Duration(minutes: 10)),
        endTime: now.add(const Duration(minutes: 50)),
        type: SessionType.study,
        completed: false,
      );
      final context = LifeContext(plannerSessions: [session]);
      expect(context.topRecommendation, contains('Deep Work Session'));
    });

    test('toPlannerContext converts context correctly', () {
      final profile = ProfileEntity(
        id: 'u1',
        displayName: 'Alex',
        email: 'alex@example.com',
        country: 'US',
        timeZone: 'UTC',
        wakeUpTime: '07:00',
        sleepTime: '23:00',
        preferredStudyStart: '09:00',
        preferredStudyEnd: '17:00',
        dailyStudyGoalMinutes: 120,
        onboardingCompleted: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final task = TaskEntity(
        id: 't1',
        title: 'Study Flutter',
        description: 'Read docs',
        category: 'Study',
        estimatedMinutes: 45,
        priority: TaskPriority.high,
        status: TaskStatus.pending,
        dueDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final context = LifeContext(
        profile: profile,
        pendingTasks: [task],
      );

      final plannerContext = context.toPlannerContext();
      expect(plannerContext.profile.displayName, 'Alex');
      expect(plannerContext.tasks.length, 1);
      expect(plannerContext.energyLevel, EnergyLevel.medium);
    });

    test('toPromptContext generates formatted string containing user info', () {
      final profile = ProfileEntity(
        id: 'u1',
        displayName: 'Jordan',
        email: 'jordan@example.com',
        country: 'US',
        timeZone: 'UTC',
        wakeUpTime: '06:30',
        sleepTime: '22:30',
        preferredStudyStart: '08:00',
        preferredStudyEnd: '16:00',
        dailyStudyGoalMinutes: 180,
        onboardingCompleted: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final context = LifeContext(profile: profile);
      final promptText = context.toPromptContext();
      expect(promptText, contains('USER: Jordan'));
      expect(promptText, contains('ENERGY: medium'));
    });
  });
}
