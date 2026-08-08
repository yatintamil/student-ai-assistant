import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/ai/ai_planner_service.dart';
import '../../../../core/services/life_context/life_context.dart';
import '../../../../features/goals/domain/entities/goal_entity.dart';
import '../../../../features/habits/domain/entities/habit_entity.dart';
import '../../../../features/profile/domain/entities/profile_entity.dart';
import '../../../../features/tasks/domain/entities/task_entity.dart';
import '../../domain/entities/planner_context.dart';
import '../../domain/entities/planner_reasoning.dart';
import '../../domain/entities/planner_session_entity.dart';
import '../../domain/repositories/planner_repository.dart';
import '../providers/planner_providers.dart';
import '../states/planner_state.dart';

/// Owns planner presentation state and generates today's schedule using the
/// new 5-stage AI reasoning architecture.
///
/// The controller orchestrates:
/// - Stage 1: Context building (collects all required data)
/// - Delegates Stages 2-5 to [AiPlannerService]
/// - Persists the validated schedule to Firestore
///
/// The AI service never writes directly to Firestore — the controller is
/// responsible for all persistence operations.
class PlannerController extends Notifier<PlannerState> {
  late PlannerRepository _repository;
  late AiPlannerService _aiService;

  @override
  PlannerState build() {
    _repository = ref.read(plannerRepositoryProvider);
    _aiService = ref.read(aiPlannerServiceProvider);
    return PlannerState.initial();
  }

  // ===========================================================================
  // STAGE 1: CONTEXT BUILDER
  // ===========================================================================

  /// Builds a consolidated [PlannerContext] from all required data sources.
  ///
  /// The planner NEVER directly accesses repositories. Instead, the controller
  /// collects all information and passes it as a single context object.
  PlannerContext _buildContext({
    required ProfileEntity profile,
    required List<TaskEntity> tasks,
    required List<HabitEntity> habits,
    List<GoalEntity> goals = const [],
    List<BusyTimeBlock> busyTimeBlocks = const [],
    EnergyLevel energyLevel = EnergyLevel.medium,
    List<TaskEntity> previousUnfinishedTasks = const [],
  }) {
    final now = DateTime.now();

    // Sort tasks by priority and deadline
    final sortedTasks = [...tasks]
      ..sort(_taskComparator);

    // Filter habits that need completion today
    final incompleteHabits = habits
        .where((h) => !h.isCompletedToday)
        .toList();

    // Calculate available minutes (wake to sleep minus busy blocks)
    final wakeTime = _parseTime(profile.wakeUpTime, now);
    final sleepTime = _parseSleepTime(profile.sleepTime, now, wakeTime);
    final totalDayMinutes = sleepTime.difference(wakeTime).inMinutes;

    final busyMinutes = busyTimeBlocks.fold<int>(
      0,
      (sum, block) => sum + block.endTime.difference(block.startTime).inMinutes,
    );

    final availableMinutes = (totalDayMinutes - busyMinutes).clamp(0, 1440);

    return PlannerContext(
      profile: profile,
      tasks: sortedTasks,
      habits: incompleteHabits,
      goals: goals.where((g) => !g.isCompleted).toList(),
      busyTimeBlocks: busyTimeBlocks,
      currentDate: now,
      availableMinutes: availableMinutes,
      energyLevel: energyLevel,
      previousUnfinishedTasks: previousUnfinishedTasks,
    );
  }

  // ===========================================================================
  // AI-ASSISTED GENERATION WITH REASONING
  // ===========================================================================

  /// Generates a plan from a unified [LifeContext] snapshot.
  Future<void> regeneratePlanFromContext({
    required String uid,
    required LifeContext lifeContext,
  }) {
    if (lifeContext.profile == null) {
      state = PlannerState.error('Complete your profile to generate a plan.');
      return Future.value();
    }
    return regeneratePlan(
      uid: uid,
      profile: lifeContext.profile!,
      tasks: lifeContext.pendingTasks,
      habits: lifeContext.todayHabits,
      goals: lifeContext.activeGoals,
      busyTimeBlocks: lifeContext.busyTimeBlocks,
      energyLevel: lifeContext.inferredEnergy,
    );
  }

  /// Simplifies the current plan from a [LifeContext] snapshot.
  Future<void> simplifyPlanFromContext({
    required String uid,
    required LifeContext lifeContext,
  }) {
    if (lifeContext.profile == null) return Future.value();
    return simplifyPlan(
      uid: uid,
      profile: lifeContext.profile!,
      tasks: lifeContext.pendingTasks,
      habits: lifeContext.todayHabits,
      goals: lifeContext.activeGoals,
      busyTimeBlocks: lifeContext.busyTimeBlocks,
      energyLevel: lifeContext.inferredEnergy,
    );
  }

  /// Fits plan into available time from a [LifeContext] snapshot.
  Future<void> fitIntoAvailableTimeFromContext({
    required String uid,
    required LifeContext lifeContext,
    required int availableMinutes,
  }) {
    if (lifeContext.profile == null) return Future.value();
    return fitIntoAvailableTime(
      uid: uid,
      profile: lifeContext.profile!,
      tasks: lifeContext.pendingTasks,
      habits: lifeContext.todayHabits,
      availableMinutes: availableMinutes,
      goals: lifeContext.activeGoals,
      busyTimeBlocks: lifeContext.busyTimeBlocks,
      energyLevel: lifeContext.inferredEnergy,
    );
  }

  /// Generates a full day schedule using the new 5-stage reasoning architecture.
  ///
  /// Stage 1: Build context (done here)
  /// Stages 2-5: Delegated to AI service
  Future<void> regeneratePlan({
    required String uid,
    required ProfileEntity profile,
    required List<TaskEntity> tasks,
    required List<HabitEntity> habits,
    List<GoalEntity> goals = const [],
    List<BusyTimeBlock> busyTimeBlocks = const [],
    EnergyLevel energyLevel = EnergyLevel.medium,
  }) async {
    state = PlannerState.loading();
    try {
      // Stage 1: Build context
      final context = _buildContext(
        profile: profile,
        tasks: tasks,
        habits: habits,
        goals: goals,
        busyTimeBlocks: busyTimeBlocks,
        energyLevel: energyLevel,
      );

      // Stages 2-5: Call AI service
      final reasoning = await _aiService.generatePlanWithReasoning(
        context: context,
      );

      // Persist the validated schedule
      await _repository.clearSessionsForDate(uid, DateTime.now());
      await _repository.saveSessions(uid, reasoning.sessions);

      state = PlannerState.loadedWithReasoning(reasoning);
    } catch (error) {
      // If AI fails (App Check token, quota, offline), fall back to rule-based schedule
      try {
        final fallbackSessions = _buildPlan(
          profile: profile,
          tasks: tasks,
          habits: habits,
          busyTimeBlocks: busyTimeBlocks,
        );
        await _repository.clearSessionsForDate(uid, DateTime.now());
        await _repository.saveSessions(uid, fallbackSessions);
        state = PlannerState.loaded(fallbackSessions);
      } catch (_) {
        state = PlannerState.error(_errorMessage(error));
      }
    }
  }

  /// Simplifies the current plan using AI reasoning.
  Future<void> simplifyPlan({
    required String uid,
    required ProfileEntity profile,
    required List<TaskEntity> tasks,
    required List<HabitEntity> habits,
    List<GoalEntity> goals = const [],
    List<BusyTimeBlock> busyTimeBlocks = const [],
    EnergyLevel energyLevel = EnergyLevel.medium,
  }) async {
    final currentSessions = state.sessions;
    if (currentSessions.isEmpty) return;

    state = PlannerState.loading();
    try {
      // Build context
      final context = _buildContext(
        profile: profile,
        tasks: tasks,
        habits: habits,
        goals: goals,
        busyTimeBlocks: busyTimeBlocks,
        energyLevel: energyLevel,
      );

      // Build current reasoning from state
      final currentReasoning = PlannerReasoning(
        sessions: currentSessions,
        reasoning: state.reasoning ?? '',
        orderRationale: state.orderRationale ?? '',
        recommendedHabits: state.recommendedHabits,
        warnings: state.warnings,
        totalScheduledMinutes: currentSessions.fold<int>(
          0,
          (sum, s) => sum + s.duration.inMinutes,
        ),
        deepWorkBlocks: 0,
        breakCount: 0,
      );

      // Call AI to simplify
      final reasoning = await _aiService.simplifyPlanWithReasoning(
        context: context,
        currentPlan: currentReasoning,
      );

      // Persist
      await _repository.clearSessionsForDate(uid, DateTime.now());
      await _repository.saveSessions(uid, reasoning.sessions);

      state = PlannerState.loadedWithReasoning(reasoning);
    } catch (error) {
      state = PlannerState.error(_errorMessage(error));
    }
  }

  /// Fits tasks and habits into available time window using AI reasoning.
  Future<void> fitIntoAvailableTime({
    required String uid,
    required ProfileEntity profile,
    required List<TaskEntity> tasks,
    required List<HabitEntity> habits,
    required int availableMinutes,
    List<GoalEntity> goals = const [],
    List<BusyTimeBlock> busyTimeBlocks = const [],
    EnergyLevel energyLevel = EnergyLevel.medium,
  }) async {
    if (availableMinutes <= 0) {
      state = PlannerState.error('Available minutes must be greater than 0.');
      return;
    }

    state = PlannerState.loading();
    try {
      // Build context with explicit available minutes
      final context = _buildContext(
        profile: profile,
        tasks: tasks,
        habits: habits,
        goals: goals,
        busyTimeBlocks: busyTimeBlocks,
        energyLevel: energyLevel,
      );

      // Override available minutes
      final contextWithTime = PlannerContext(
        profile: context.profile,
        tasks: context.tasks,
        habits: context.habits,
        goals: context.goals,
        busyTimeBlocks: context.busyTimeBlocks,
        currentDate: context.currentDate,
        availableMinutes: availableMinutes,
        energyLevel: context.energyLevel,
        previousUnfinishedTasks: context.previousUnfinishedTasks,
      );

      // Call AI
      final reasoning = await _aiService.fitIntoAvailableTimeWithReasoning(
        context: contextWithTime,
      );

      // Persist
      await _repository.clearSessionsForDate(uid, DateTime.now());
      await _repository.saveSessions(uid, reasoning.sessions);

      state = PlannerState.loadedWithReasoning(reasoning);
    } catch (error) {
      state = PlannerState.error(_errorMessage(error));
    }
  }

  // ===========================================================================
  // DETERMINISTIC FALLBACK (when AI fails)
  // ===========================================================================

  /// Generates a simple rule-based plan without AI (fallback mode).
  Future<void> generateTodayPlan({
    required String uid,
    required ProfileEntity profile,
    required List<TaskEntity> tasks,
    required List<HabitEntity> habits,
    List<BusyTimeBlock> busyTimeBlocks = const [],
  }) async {
    state = PlannerState.loading();
    try {
      final sessions = _buildPlan(
        profile: profile,
        tasks: tasks,
        habits: habits,
        busyTimeBlocks: busyTimeBlocks,
      );
      await _repository.clearSessionsForDate(uid, DateTime.now());
      await _repository.saveSessions(uid, sessions);
      state = PlannerState.loaded(sessions);
    } catch (error) {
      state = PlannerState.error(_errorMessage(error));
    }
  }

  // ===========================================================================
  // RELOAD & COMPLETION
  // ===========================================================================

  /// Reloads the persisted plan for today without regenerating it.
  Future<void> refreshPlan(String uid) async {
    state = PlannerState.loading();
    try {
      final sessions =
          await _repository.getSessionsForDate(uid, DateTime.now());
      state = PlannerState.loaded(sessions);
    } catch (error) {
      state = PlannerState.error(_errorMessage(error));
    }
  }

  /// Marks the session identified by [sessionId] as completed, both locally
  /// (optimistic) and in Firestore.
  Future<void> markCompleted(String uid, String sessionId) async {
    state = state.withSessionCompleted(sessionId);
    try {
      await _repository.markSessionCompleted(uid, sessionId);
    } catch (error) {
      state = PlannerState.error(_errorMessage(error));
    }
  }

  // ===========================================================================
  // DETERMINISTIC PLAN BUILDER (Fallback Mode)
  // ===========================================================================

  List<PlannerSessionEntity> _buildPlan({
    required ProfileEntity profile,
    required List<TaskEntity> tasks,
    required List<HabitEntity> habits,
    List<BusyTimeBlock> busyTimeBlocks = const [],
  }) {
    final today = DateTime.now();
    final wakeTime = _parseTime(profile.wakeUpTime, today);
    final sleepTime = _parseSleepTime(profile.sleepTime, today, wakeTime);

    final sessions = <PlannerSessionEntity>[];
    var cursor = wakeTime;

    // 1. Morning Wake & Prepare
    cursor = _addSession(
      sessions: sessions,
      start: cursor,
      durationMinutes: 15,
      title: 'Wake up & prepare',
      type: SessionType.other,
    );

    // 2. Breakfast
    if (cursor.hour < 9) {
      cursor = _addSession(
        sessions: sessions,
        start: cursor,
        durationMinutes: 30,
        title: 'Breakfast & Morning Routine',
        type: SessionType.meal,
      );
    }

    final pending = tasks
        .where((t) => t.status == TaskStatus.pending)
        .toList()
      ..sort(_taskComparator);

    var sessionsSinceBreak = 0;

    // 3. Schedule Pending Tasks
    for (final task in pending) {
      if (sessionsSinceBreak >= 2) {
        cursor = _addSession(
          sessions: sessions,
          start: cursor,
          durationMinutes: 15,
          title: 'Short Break',
          type: SessionType.breakTime,
        );
        sessionsSinceBreak = 0;
      }
      if (!cursor.isBefore(sleepTime)) break;

      // Insert Lunch if cursor reaches lunchtime
      if (cursor.hour >= 12 && cursor.hour < 14 && !sessions.any((s) => s.title.contains('Lunch'))) {
        cursor = _addSession(
          sessions: sessions,
          start: cursor,
          durationMinutes: 45,
          title: 'Lunch Break & Recharge',
          type: SessionType.meal,
        );
      }

      final minutes = task.estimatedMinutes.clamp(15, 120);
      cursor = _addSession(
        sessions: sessions,
        start: cursor,
        durationMinutes: minutes,
        title: task.title,
        type: SessionType.study,
        linkedTaskId: task.id,
      );
      sessionsSinceBreak++;
    }

    // 4. Schedule Incomplete Habits
    final incompleteHabits = habits.where((h) => !h.isCompletedToday).toList();
    for (final habit in incompleteHabits) {
      if (!cursor.isBefore(sleepTime)) break;
      if (sessionsSinceBreak >= 2) {
        cursor = _addSession(
          sessions: sessions,
          start: cursor,
          durationMinutes: 15,
          title: 'Short Break',
          type: SessionType.breakTime,
        );
        sessionsSinceBreak = 0;
      }
      cursor = _addSession(
        sessions: sessions,
        start: cursor,
        durationMinutes: 20,
        title: habit.title,
        type: SessionType.habit,
        linkedHabitId: habit.id,
      );
      sessionsSinceBreak++;
    }

    // 5. Fill remaining afternoon / evening gap up to sleep time
    if (cursor.isBefore(sleepTime.subtract(const Duration(minutes: 60)))) {
      // Lunch check if not added yet
      if (cursor.hour < 14 && !sessions.any((s) => s.title.contains('Lunch'))) {
        cursor = _addSession(
          sessions: sessions,
          start: cursor,
          durationMinutes: 45,
          title: 'Lunch Break & Recharge',
          type: SessionType.meal,
        );
      }

      // Afternoon / Evening Focus & Self-Study Session
      final gapMinutes = sleepTime.difference(cursor).inMinutes - 90;
      if (gapMinutes > 30) {
        cursor = _addSession(
          sessions: sessions,
          start: cursor,
          durationMinutes: gapMinutes.clamp(30, 180),
          title: 'Self-Study & Goal Advancement',
          type: SessionType.study,
        );
      }

      // Dinner
      if (cursor.hour >= 18 && cursor.hour < 21 && !sessions.any((s) => s.title.contains('Dinner'))) {
        cursor = _addSession(
          sessions: sessions,
          start: cursor,
          durationMinutes: 45,
          title: 'Dinner & Relaxation',
          type: SessionType.meal,
        );
      }

      // Evening Review & Wind down
      if (cursor.isBefore(sleepTime)) {
        final windDownMins = sleepTime.difference(cursor).inMinutes.clamp(15, 90);
        cursor = _addSession(
          sessions: sessions,
          start: cursor,
          durationMinutes: windDownMins,
          title: 'Evening Review & Night Wind-down',
          type: SessionType.other,
        );
      }
    }

    // 6. Sleep
    sessions.add(
      PlannerSessionEntity(
        id: const Uuid().v4(),
        title: 'Sleep',
        startTime: sleepTime,
        endTime: sleepTime.add(const Duration(hours: 8)),
        type: SessionType.sleep,
        completed: false,
      ),
    );

    return sessions;
  }

  DateTime _addSession({
    required List<PlannerSessionEntity> sessions,
    required DateTime start,
    required int durationMinutes,
    required String title,
    required SessionType type,
    String? linkedTaskId,
    String? linkedHabitId,
  }) {
    final end = start.add(Duration(minutes: durationMinutes));
    sessions.add(
      PlannerSessionEntity(
        id: const Uuid().v4(),
        title: title,
        startTime: start,
        endTime: end,
        type: type,
        completed: false,
        linkedTaskId: linkedTaskId,
        linkedHabitId: linkedHabitId,
      ),
    );
    return end;
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
    final sleepCandidate = _parseTime(hhmm, date);
    if (sleepCandidate.isAfter(wakeTime)) return sleepCandidate;
    return sleepCandidate.add(const Duration(days: 1));
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

  String _errorMessage(Object error) {
    if (error is AiPlannerException) return error.message;
    if (error is String) return error;
    return 'Something went wrong. Please try again.';
  }
}
