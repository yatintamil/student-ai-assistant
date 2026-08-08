import 'package:equatable/equatable.dart';

import '../../../features/goals/domain/entities/goal_entity.dart';
import '../../../features/habits/domain/entities/habit_entity.dart';
import '../../../features/journal/domain/entities/journal_entity.dart';
import '../../../features/planner/domain/entities/planner_context.dart';
import '../../../features/planner/domain/entities/planner_session_entity.dart';
import '../../../features/profile/domain/entities/profile_entity.dart';
import '../../../features/tasks/domain/entities/task_entity.dart';

/// Unified snapshot of the user's life data for AI reasoning.
///
/// Every AI touchpoint — planner, chat, dashboard insights — reads from this
/// object so recommendations stay goal-aligned and context-aware.
class LifeContext extends Equatable {
  const LifeContext({
    this.profile,
    this.activeGoals = const [],
    this.pendingTasks = const [],
    this.todayHabits = const [],
    this.plannerSessions = const [],
    this.latestJournal,
    this.busyTimeBlocks = const [],
  });

  final ProfileEntity? profile;
  final List<GoalEntity> activeGoals;
  final List<TaskEntity> pendingTasks;
  final List<HabitEntity> todayHabits;
  final List<PlannerSessionEntity> plannerSessions;
  final JournalEntity? latestJournal;
  final List<BusyTimeBlock> busyTimeBlocks;

  /// Energy level inferred from the latest journal entry, or medium by default.
  EnergyLevel get inferredEnergy {
    final energy = latestJournal?.energyLevel;
    if (energy == null) return EnergyLevel.medium;
    if (energy <= 3) return EnergyLevel.low;
    if (energy >= 8) return EnergyLevel.high;
    return EnergyLevel.medium;
  }

  /// The session happening right now, if any.
  PlannerSessionEntity? get currentSession {
    try {
      return plannerSessions.firstWhere((s) => s.isActive);
    } catch (_) {
      return null;
    }
  }

  /// The next upcoming session that hasn't started yet.
  PlannerSessionEntity? get nextSession {
    final now = DateTime.now();
    try {
      return plannerSessions.firstWhere(
        (s) => s.startTime.isAfter(now) && !s.completed,
      );
    } catch (_) {
      return null;
    }
  }

  /// Best actionable recommendation based on current context.
  String get topRecommendation {
    if (currentSession != null && !currentSession!.completed) {
      return 'Focus on "${currentSession!.title}" — it\'s your current session.';
    }
    if (nextSession != null) {
      return 'Up next: "${nextSession!.title}". Prepare and start when ready.';
    }

    final urgent = pendingTasks
        .where((t) => t.status == TaskStatus.pending)
        .toList()
      ..sort(_taskComparator);
    if (urgent.isNotEmpty) {
      final top = urgent.first;
      final goalHint = _goalTitleForTask(top.goalId);
      final suffix = goalHint != null ? ' (supports: $goalHint)' : '';
      return 'Tackle "${top.title}" — highest priority pending task$suffix.';
    }

    final streakHabits = todayHabits
        .where((h) => h.currentStreak > 0 && !h.isCompletedToday)
        .toList();
    if (streakHabits.isNotEmpty) {
      return 'Protect your ${streakHabits.first.currentStreak}-day streak: complete "${streakHabits.first.title}".';
    }

    if (activeGoals.isNotEmpty) {
      final topGoal = activeGoals.first;
      return 'Review progress on "${topGoal.title}" and define one concrete step for today.';
    }

    return 'Set a goal and add tasks so I can recommend what moves you forward.';
  }

  /// Builds a [PlannerContext] for the AI planner service.
  PlannerContext toPlannerContext() {
    if (profile == null) {
      throw StateError('Profile is required to build a planner context.');
    }

    final now = DateTime.now();
    final sortedTasks = pendingTasks.where((t) => t.status == TaskStatus.pending).toList()
      ..sort(_taskComparator);
    final incompleteHabits =
        todayHabits.where((h) => !h.isCompletedToday).toList();

    final wakeTime = _parseTime(profile!.wakeUpTime, now);
    final sleepTime = _parseSleepTime(profile!.sleepTime, now, wakeTime);
    final totalDayMinutes = sleepTime.difference(wakeTime).inMinutes;
    final busyMinutes = busyTimeBlocks.fold<int>(
      0,
      (sum, block) =>
          sum + block.endTime.difference(block.startTime).inMinutes,
    );

    return PlannerContext(
      profile: profile!,
      tasks: sortedTasks,
      habits: incompleteHabits,
      goals: activeGoals.where((g) => !g.isCompleted).toList(),
      busyTimeBlocks: busyTimeBlocks,
      currentDate: now,
      availableMinutes: (totalDayMinutes - busyMinutes).clamp(0, 1440),
      energyLevel: inferredEnergy,
      previousUnfinishedTasks: const [],
    );
  }

  /// Structured text for Gemini prompts in chat and insights.
  String toPromptContext() {
    final buffer = StringBuffer();
    final now = DateTime.now();

    if (profile != null) {
      buffer.writeln('USER: ${profile!.displayName}');
      buffer.writeln(
        'Schedule: wake ${profile!.wakeUpTime}, sleep ${profile!.sleepTime}',
      );
      buffer.writeln(
        'Daily focus goal: ${profile!.dailyStudyGoalMinutes} minutes',
      );
    }

    buffer.writeln('DATE: ${now.year}-${now.month}-${now.day}');
    buffer.writeln('ENERGY: ${inferredEnergy.name}');

    if (activeGoals.isNotEmpty) {
      buffer.writeln('\nACTIVE GOALS:');
      for (final goal in activeGoals.where((g) => !g.isCompleted)) {
        buffer.writeln(
          '- [${goal.level.name}/${goal.category.name}] ${goal.title} '
          '(${ (goal.progress * 100).round() }% progress)',
        );
      }
    }

    final pending = pendingTasks
        .where((t) => t.status == TaskStatus.pending)
        .toList()
      ..sort(_taskComparator);
    if (pending.isNotEmpty) {
      buffer.writeln('\nPENDING TASKS (${pending.length}):');
      for (final task in pending.take(10)) {
        buffer.writeln(
          '- [${task.priority.name}] ${task.title} '
          '(due ${task.dueDate.month}/${task.dueDate.day}, '
          '${task.estimatedMinutes}min)',
        );
      }
    }

    final incompleteHabits =
        todayHabits.where((h) => !h.isCompletedToday).toList();
    if (incompleteHabits.isNotEmpty) {
      buffer.writeln('\nHABITS DUE TODAY:');
      for (final habit in incompleteHabits) {
        buffer.writeln(
          '- ${habit.title} (${habit.currentStreak}-day streak)',
        );
      }
    }

    if (currentSession != null) {
      buffer.writeln('\nCURRENT SESSION: ${currentSession!.title}');
    } else if (nextSession != null) {
      buffer.writeln('\nNEXT SESSION: ${nextSession!.title}');
    }

    if (latestJournal != null) {
      buffer.writeln('\nLATEST JOURNAL:');
      buffer.writeln(
        '- Mood: ${latestJournal!.mood.name}, '
        'Energy: ${latestJournal!.energyLevel}/10',
      );
      if (latestJournal!.wins.isNotEmpty) {
        buffer.writeln('- Recent win: ${latestJournal!.wins.first}');
      }
    }

    buffer.writeln('\nTOP RECOMMENDATION: $topRecommendation');
    return buffer.toString();
  }

  String? _goalTitleForTask(String? goalId) {
    if (goalId == null) return null;
    try {
      return activeGoals.firstWhere((g) => g.id == goalId).title;
    } catch (_) {
      return null;
    }
  }

  static int _taskComparator(TaskEntity a, TaskEntity b) {
    const order = {
      TaskPriority.high: 0,
      TaskPriority.medium: 1,
      TaskPriority.low: 2,
    };
    final priorityDiff =
        (order[a.priority] ?? 1) - (order[b.priority] ?? 1);
    if (priorityDiff != 0) return priorityDiff;
    return a.dueDate.compareTo(b.dueDate);
  }

  static DateTime _parseTime(String hhmm, DateTime date) {
    final parts = hhmm.split(':');
    final hour = int.tryParse(parts.isNotEmpty ? parts[0] : '7') ?? 7;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  static DateTime _parseSleepTime(
    String hhmm,
    DateTime date,
    DateTime wakeTime,
  ) {
    final parsed = _parseTime(hhmm, date);
    return parsed.isBefore(wakeTime)
        ? parsed.add(const Duration(days: 1))
        : parsed;
  }

  @override
  List<Object?> get props => [
        profile,
        activeGoals,
        pendingTasks,
        todayHabits,
        plannerSessions,
        latestJournal,
        busyTimeBlocks,
      ];
}
