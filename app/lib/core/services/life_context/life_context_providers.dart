import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/goals/presentation/providers/goal_providers.dart';
import '../../../features/habits/presentation/providers/habit_providers.dart';
import '../../../features/calendar/presentation/providers/calendar_providers.dart';
import '../../../features/planner/domain/entities/planner_context.dart';
import '../../../features/journal/domain/entities/journal_entity.dart';
import '../../../features/journal/presentation/providers/journal_providers.dart';
import '../../../features/planner/presentation/providers/planner_providers.dart';
import '../../../features/profile/presentation/providers/profile_providers.dart';
import '../../../features/tasks/presentation/providers/task_providers.dart';
import 'life_context.dart';

/// Reactive provider that assembles a [LifeContext] from all feature states.
///
/// Watches profile, goals, tasks, habits, planner sessions, and journal
/// entries so any AI surface always has up-to-date life data.
final lifeContextProvider = Provider<LifeContext>((ref) {
  final profile = ref.watch(profileControllerProvider).profile;
  final goals = ref.watch(goalControllerProvider).goals;
  final tasks = ref.watch(taskControllerProvider).tasks;
  final habits = ref.watch(habitControllerProvider).habits;
  final plannerSessions = ref.watch(plannerControllerProvider).sessions;
  final calendarEvents = ref.watch(calendarControllerProvider).events;
  final journalEntries = ref.watch(journalControllerProvider).entries;

  JournalEntity? latestJournal;
  if (journalEntries.isNotEmpty) {
    final sorted = [...journalEntries]
      ..sort((a, b) => b.date.compareTo(a.date));
    latestJournal = sorted.first;
  }

  return LifeContext(
    profile: profile,
    activeGoals: goals.where((g) => !g.isCompleted).toList(),
    pendingTasks: tasks,
    todayHabits: habits,
    plannerSessions: plannerSessions,
    latestJournal: latestJournal,
    busyTimeBlocks: calendarEvents.where((event) => !event.isFlexible).map((event) => BusyTimeBlock(title: event.title, startTime: event.startTime, endTime: event.endTime)).toList(),
  );
});
