import 'package:equatable/equatable.dart';

import '../../../goals/domain/entities/goal_entity.dart';
import '../../../habits/domain/entities/habit_entity.dart';
import '../../../profile/domain/entities/profile_entity.dart';
import '../../../tasks/domain/entities/task_entity.dart';

/// Energy level for scheduling optimization.
enum EnergyLevel {
  /// Low energy - suitable for light tasks.
  low,

  /// Medium energy - suitable for moderate tasks.
  medium,

  /// High energy - suitable for deep work and difficult tasks.
  high,
}

/// Represents a busy time block in the user's calendar.
class BusyTimeBlock extends Equatable {
  /// Creates a busy time block.
  const BusyTimeBlock({
    required this.title,
    required this.startTime,
    required this.endTime,
    this.isFlexible = false,
  });

  /// Title of the event.
  final String title;

  /// Start time of the busy period.
  final DateTime startTime;

  /// End time of the busy period.
  final DateTime endTime;

  /// Whether this event can be rescheduled if needed.
  final bool isFlexible;

  @override
  List<Object?> get props => [title, startTime, endTime, isFlexible];
}

/// Consolidated context for AI planner.
///
/// Stage 1: Context Builder
/// This object contains ALL information the planner needs without directly
/// accessing repositories. The controller builds this once and passes it to
/// the AI service.
class PlannerContext extends Equatable {
  /// Creates a planner context.
  const PlannerContext({
    required this.profile,
    required this.tasks,
    required this.habits,
    this.goals = const [],
    required this.busyTimeBlocks,
    required this.currentDate,
    required this.availableMinutes,
    required this.energyLevel,
    required this.previousUnfinishedTasks,
  });

  /// User profile containing wake/sleep times, timezone, study preferences.
  final ProfileEntity profile;

  /// All pending tasks to be scheduled, pre-sorted by priority and deadline.
  final List<TaskEntity> tasks;

  /// All habits that need to be completed today.
  final List<HabitEntity> habits;

  /// User active goals across vision, long-term, quarterly, weekly levels.
  final List<GoalEntity> goals;

  /// Fixed calendar events that block scheduling time.
  final List<BusyTimeBlock> busyTimeBlocks;

  /// Today's date for scheduling.
  final DateTime currentDate;

  /// Total minutes available for scheduling (wake to sleep minus busy blocks).
  final int availableMinutes;

  /// Current energy level of the user for optimization.
  final EnergyLevel energyLevel;

  /// Tasks from previous days that weren't completed.
  final List<TaskEntity> previousUnfinishedTasks;

  /// Calculates total free time windows between busy blocks.
  List<Duration> get freeTimeWindows {
    if (busyTimeBlocks.isEmpty) {
      return [Duration(minutes: availableMinutes)];
    }

    final windows = <Duration>[];
    final sorted = [...busyTimeBlocks]
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final wakeTime = _parseTime(profile.wakeUpTime, currentDate);
    
    // Window before first busy block
    if (sorted.first.startTime.isAfter(wakeTime)) {
      windows.add(sorted.first.startTime.difference(wakeTime));
    }

    // Windows between busy blocks
    for (var i = 0; i < sorted.length - 1; i++) {
      final gap = sorted[i + 1].startTime.difference(sorted[i].endTime);
      if (gap.inMinutes > 0) {
        windows.add(gap);
      }
    }

    // Window after last busy block
    final sleepTime = _parseSleepTime(profile.sleepTime, currentDate, wakeTime);
    if (sleepTime.isAfter(sorted.last.endTime)) {
      windows.add(sleepTime.difference(sorted.last.endTime));
    }

    return windows;
  }

  /// Calculates total busy time in minutes.
  int get busyMinutes {
    return busyTimeBlocks.fold(
      0,
      (sum, block) => sum + block.endTime.difference(block.startTime).inMinutes,
    );
  }

  /// High priority tasks count.
  int get highPriorityTasksCount {
    return tasks.where((t) => t.priority == TaskPriority.high).length;
  }

  /// Tasks with approaching deadlines (within 3 days).
  List<TaskEntity> get urgentTasks {
    final now = currentDate;
    final threeDaysLater = now.add(const Duration(days: 3));
    return tasks
        .where((t) => t.dueDate.isBefore(threeDaysLater))
        .toList();
  }

  /// Habits with current streaks at risk (not completed today).
  List<HabitEntity> get streakRiskHabits {
    return habits
        .where((h) => h.currentStreak > 0 && !h.isCompletedToday)
        .toList();
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
    return parsed.isBefore(wakeTime) ? parsed.add(const Duration(days: 1)) : parsed;
  }

  @override
  List<Object?> get props => [
        profile,
        tasks,
        habits,
        goals,
        busyTimeBlocks,
        currentDate,
        availableMinutes,
        energyLevel,
        previousUnfinishedTasks,
      ];
}
