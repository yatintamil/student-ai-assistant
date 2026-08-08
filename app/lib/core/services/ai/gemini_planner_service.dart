import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:uuid/uuid.dart';

import '../../../core/config/gemini_config.dart';
import '../../../features/planner/domain/entities/planner_context.dart';
import '../../../features/planner/domain/entities/planner_reasoning.dart';
import '../../../features/planner/domain/entities/planner_session_entity.dart';
import '../../../features/planner/domain/entities/recommended_habit.dart';
import 'ai_planner_service.dart';

/// Gemini-backed implementation of [AiPlannerService] with 5-stage architecture.
///
/// This service acts as a reasoning engine:
/// - Stage 1: Context is pre-built by controller
/// - Stage 2: Build structured prompts that explain the user's life
/// - Stage 3: Gemini reasons first, then generates JSON
/// - Stage 4: Comprehensive validation
/// - Stage 5: Schedule optimization
class GeminiPlannerService implements AiPlannerService {
  /// Creates a [GeminiPlannerService].
  ///
  /// Uses Google Generative AI for AI requests.
  GeminiPlannerService({
    String modelName = GeminiConfig.defaultModel,
    String? apiKey,
  }) : _model = GenerativeModel(
          model: modelName,
          apiKey: apiKey ?? GeminiConfig.apiKey,
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
          ),
        );

  final GenerativeModel _model;

  // ===========================================================================
  // PUBLIC API
  // ===========================================================================

  @override
  Future<PlannerReasoning> generatePlanWithReasoning({
    required PlannerContext context,
  }) async {
    // Stage 2: Build structured prompt
    final prompt = _buildReasoningPrompt(context);

    // Stage 3: Call Gemini to eason and generate
    final rawResponse = await _callGemini(prompt);

    // Parse response
    final parsed = _parseReasoningResponse(rawResponse, context);

    // Stage 4: Validate
    _validateSessions(parsed.sessions, context);

    // Stage 5: Optimize
    final optimized = _optimizeSchedule(parsed, context);

    return optimized;
  }

  @override
  Future<PlannerReasoning> simplifyPlanWithReasoning({
    required PlannerContext context,
    required PlannerReasoning currentPlan,
  }) async {
    final prompt = _buildSimplifyPrompt(context, currentPlan);
    final rawResponse = await _callGemini(prompt);
    final parsed = _parseReasoningResponse(rawResponse, context);
    _validateSessions(parsed.sessions, context);
    return _optimizeSchedule(parsed, context);
  }

  @override
  Future<PlannerReasoning> fitIntoAvailableTimeWithReasoning({
    required PlannerContext context,
  }) async {
    final prompt = _buildFitPrompt(context);
    final rawResponse = await _callGemini(prompt);
    final parsed = _parseReasoningResponse(rawResponse, context);
    _validateSessions(parsed.sessions, context);
    return _optimizeSchedule(parsed, context);
  }

  // ===========================================================================
  // STAGE 2: PROMPT BUILDER
  // ===========================================================================

  /// Builds a structured prompt that explains the user's life, goals, and context.
  String _buildReasoningPrompt(PlannerContext context) {
    final profile = context.profile;
    final wakeTime = profile.wakeUpTime;
    final sleepTime = profile.sleepTime;
    final studyGoal = profile.dailyStudyGoalMinutes;
    final availableMinutes = context.availableMinutes;

    // Build task list with rich context
    final taskLines = context.tasks.map((t) {
      final urgency = t.dueDate.difference(context.currentDate).inDays;
      final urgencyLabel = urgency <= 1
          ? 'URGENT (due in $urgency day${urgency == 1 ? '' : 's'})'
          : 'due in $urgency days';

      return '  - "${t.title}"\n'
          '    Priority: ${t.priority.name.toUpperCase()}\n'
          '    Duration: ${t.estimatedMinutes} min\n'
          '    Deadline: $urgencyLabel\n'
          '    Description: ${t.description}\n'
          '    TaskID: ${t.id}';
    }).join('\n\n');

    // Build habit list
    final habitLines = context.habits.map((h) {
      final streakInfo = h.currentStreak > 0
          ? ' (${h.currentStreak}-day streak at risk!)'
          : '';
      return '  - "${h.title}"$streakInfo\n'
          '    Frequency: ${h.frequency.name}\n'
          '    HabitID: ${h.id}';
    }).join('\n\n');

    // Build busy blocks
    final busyBlocks = context.busyTimeBlocks.map((b) {
      return '  - ${_formatTime(b.startTime)} - ${_formatTime(b.endTime)}: ${b.title}';
    }).join('\n');

    final busySection = context.busyTimeBlocks.isEmpty
        ? 'NONE - Full day is available'
        : busyBlocks;

    // Build goal list
    final goalLines = context.goals.map((g) {
      return '  - "${g.title}" (${g.level.name.toUpperCase()} Goal - ${g.category.name})\n'
          '    Description: ${g.description}\n'
          '    Progress: ${(g.progress * 100).toInt()}%';
    }).join('\n\n');

    return '''
You are an expert AI productivity chief of staff with deep expertise in:
- Long-term life planning & goal alignment
- Project management and deadline prioritization
- Cognitive science and focus optimization
- Time management and habit formation

Your core philosophy: Answer "What is the best thing I should do right now to get closer to my goals?" and generate a schedule aligned with long-term objectives.

═══════════════════════════════════════════════════════════════
USER PROFILE & OBJECTIVES
═══════════════════════════════════════════════════════════════
Name: ${profile.displayName}
Wake-up time: $wakeTime
Sleep time: $sleepTime
Timezone: ${profile.timeZone}
Study preference: ${profile.preferredStudyStart} - ${profile.preferredStudyEnd}
Daily study goal: $studyGoal minutes
Today: ${_formatDate(context.currentDate)}
Available time: $availableMinutes minutes
Current energy level: ${context.energyLevel.name}

═══════════════════════════════════════════════════════════════
ACTIVE LIFE GOALS
═══════════════════════════════════════════════════════════════
${goalLines.isEmpty ? 'No active goals set' : goalLines}

═══════════════════════════════════════════════════════════════
PENDING TASKS (Sorted by Priority)
═══════════════════════════════════════════════════════════════
${taskLines.isEmpty ? 'No pending tasks' : taskLines}

═══════════════════════════════════════════════════════════════
INCOMPLETE HABITS FOR TODAY
═══════════════════════════════════════════════════════════════
${habitLines.isEmpty ? 'All habits completed' : habitLines}

═══════════════════════════════════════════════════════════════
BUSY TIME BLOCKS (Fixed Calendar Events)
═══════════════════════════════════════════════════════════════
$busySection

═══════════════════════════════════════════════════════════════
PLANNING PHILOSOPHY & RULES
═══════════════════════════════════════════════════════════════
1. PRIORITY & DEADLINES
   - HIGH priority tasks MUST be scheduled first
   - Urgent deadlines take precedence
   - Long descriptions indicate complex work needing focus blocks

2. ENERGY OPTIMIZATION
   - Morning (after wake): HIGH energy - schedule deep work, complex tasks
   - Afternoon: MEDIUM energy - moderate tasks, habits
   - Evening: LOW energy - light tasks, reading, relaxation
   - Current energy: ${context.energyLevel.name}

3. FOCUS & BREAKS
   - Deep work sessions: 90-120 minutes maximum
   - Insert 10-15 minute breaks after every 90 minutes
   - Never stack more than 2 focus blocks without a break
   - Group similar tasks to reduce context switching

4. HEALTHY SCHEDULE
   - Include 15-minute morning routine at wake time
   - Schedule meals: breakfast, lunch, dinner
   - Add sleep session at sleep time (7-8 hours)
   - Consider exercise before long study sessions (boosts focus)

5. HABITS & STREAKS
   - Prioritize habits with active streaks (show in parentheses)
   - Schedule habits at consistent times daily
   - Don't skip habits to fit more tasks

6. TASK UNDERSTANDING
   - Analyze task descriptions for complexity
   - "architecture", "design", "complex" → 90-120 min blocks
   - "review", "quick", "simple" → 30-45 min blocks
   - Respect estimatedMinutes but adjust if unrealistic

7. FULL-DAY COVERAGE (CRITICAL)
   - You MUST generate a continuous, realistic schedule spanning the ENTIRE waking day from wakeUpTime to sleepTime.
   - Never leave unallocated gaps larger than 30 minutes.
   - Fill open time with structured focus blocks for active goals, self-study, meals (breakfast, lunch, dinner), breaks, and evening review/relaxation.

8. AVOID
   - No overlapping sessions
   - No scheduling past sleep time
   - No unrealistic task stacking
   - No skipping essential breaks

═══════════════════════════════════════════════════════════════
REQUIRED OUTPUT FORMAT
═══════════════════════════════════════════════════════════════
Return a JSON object with this EXACT structure:

{
  "reasoning": "string - Overall reasoning for schedule structure",
  "orderRationale": "string - Why sessions are ordered this way",
  "sessions": [
    {
      "title": "string",
      "startTime": "HH:mm",
      "endTime": "HH:mm",
      "type": "study|habit|breakTime|meal|exercise|sleep|other",
      "reason": "string - Why scheduled at this time",
      "energyLevel": "low|medium|high",
      "priority": number (1=highest, 10=lowest),
      "linkedTaskId": "string or null",
      "linkedHabitId": "string or null"
    }
  ],
  "warnings": [
    {
      "message": "string",
      "severity": "info|warning|critical",
      "suggestion": "string or null"
    }
  ],
  "recommendedHabits": [
    {
      "title": "string",
      "reason": "string",
      "currentBehavior": "string",
      "suggestedBehavior": "string"
    }
  ]
}

Think step-by-step:
1. What are the high-priority/urgent items?
2. When is the user's energy highest?
3. How can I group similar work?
4. Where do breaks and meals fit?
5. Are there any warnings about this schedule?
6. What habit improvements would help achieve goals?

Generate the JSON now.
''';
  }

  /// Builds prompt for simplifying an existing schedule.
  String _buildSimplifyPrompt(
    PlannerContext context,
    PlannerReasoning currentPlan,
  ) {
    final sessionLines = currentPlan.sessions.map((s) {
      return '  ${_formatTime(s.startTime)} - ${_formatTime(s.endTime)}: '
          '${s.title} (${s.type.name})';
    }).join('\n');

    return '''
You are an expert productivity planner. Simplify the schedule below while preserving its core value.

CURRENT SCHEDULE:
$sessionLines

USER CONTEXT:
Wake: ${context.profile.wakeUpTime}
Sleep: ${context.profile.sleepTime}

SIMPLIFICATION RULES:
1. Merge consecutive sessions of same type if each < 20 minutes
2. Remove completed sessions
3. Keep all uncompleted study and habit sessions
4. Preserve sleep session
5. Maintain breaks between focus blocks

Return JSON in the same format as generatePlan.
''';
  }

  /// Builds prompt for fitting tasks into limited time window.
  String _buildFitPrompt(PlannerContext context) {
    final now = DateTime.now();
    final nowLabel = _formatTime(now);

    return '''
URGENT SCHEDULING TASK

The user has only ${context.availableMinutes} minutes of free time starting NOW ($nowLabel).

Fit as many HIGH-PRIORITY items as possible into this window.

${_buildReasoningPrompt(context)}

ADDITIONAL CONSTRAINT:
- First session MUST start at $nowLabel
- Total schedule cannot exceed ${context.availableMinutes} minutes
- Prioritize ruthlessly: high → medium → low

Return JSON in the standard format.
''';
  }

  // ===========================================================================
  // STAGE 3: GEMINI CALL & PARSING
  // ===========================================================================

  Future<String> _callGemini(String prompt) async {
    try {
      // Debug: Check current user authentication
      final user = FirebaseAuth.instance.currentUser;
      debugPrint('🔍 DEBUG - Current User UID: ${user?.uid}');
      debugPrint('🔍 DEBUG - Current User Email: ${user?.email}');
      
      final response = await _model.generateContent([Content.text(prompt)]);
      final raw = response.text;
      if (raw == null || raw.trim().isEmpty) {
        throw const AiPlannerException('Gemini returned an empty response.');
      }
      return raw;
    } catch (e) {
      // Enhanced error handling for common issues
      final errorMessage = e.toString();
      
      if (errorMessage.contains('App Check') ||
          errorMessage.contains('AppCheck') ||
          errorMessage.contains('app-check')) {
        throw const AiPlannerException(
          'Firebase App Check token is invalid.\n\n'
          'To fix in Firebase Console:\n'
          '1. Go to Firebase Console → Build → App Check.\n'
          '2. Select "Unenforce" for Vertex AI / Google AI, or add your debug provider.\n'
          'Local smart fallback plan has been generated.',
        );
      }

      if (errorMessage.contains('API_KEY') || errorMessage.contains('INVALID_ARGUMENT')) {
        throw const AiPlannerException(
          'Firebase Google AI is not configured.\n\n'
          'Please ensure Google AI is enabled in Firebase Console:\n'
          'https://console.firebase.google.com/project/student-ai-assistant-dc9a8/ai\n\n'
          'Then wait 1-2 minutes and retry.',
        );
      }
      
      if (errorMessage.contains('403') || errorMessage.contains('PERMISSION_DENIED')) {
        throw const AiPlannerException(
          'Permission denied: Firebase Google AI may not be enabled.\n\n'
          'Enable it in Firebase Console → Build → AI.\n\n'
          'No Blaze plan required for Google AI!',
        );
      }
      
      if (errorMessage.contains('404') || errorMessage.contains('NOT_FOUND')) {
        throw const AiPlannerException(
          'Model not found: The requested Gemini model may not be available.\n\n'
          'Try using "gemini-3.5-flash" or "gemini-3.6-flash".',
        );
      }
      
      if (errorMessage.contains('429') || errorMessage.contains('RESOURCE_EXHAUSTED')) {
        throw const AiPlannerException(
          'Rate limit exceeded: Too many requests.\n\n'
          'Please wait a minute and try again.',
        );
      }
      
      if (errorMessage.contains('401') || errorMessage.contains('UNAUTHENTICATED')) {
        throw const AiPlannerException(
          'Authentication required: Please sign in to use AI features.\n\n'
          'Make sure you are logged in with a valid account.',
        );
      }
      
      // Generic error
      throw AiPlannerException(
        'Failed to generate plan: $errorMessage\n\n'
        'Please check your internet connection and try again.',
      );
    }
  }

  PlannerReasoning _parseReasoningResponse(
    String raw,
    PlannerContext context,
  ) {
    // Strip markdown fences
    final cleaned = raw
        .replaceAll(RegExp(r'```json\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'```\s*'), '')
        .trim();

    final Map<String, dynamic> json;
    try {
      json = jsonDecode(cleaned) as Map<String, dynamic>;
    } catch (e) {
      throw AiPlannerException(
        'Failed to parse Gemini response as JSON: $e\nRaw: $cleaned',
      );
    }

    // Parse sessions
    final sessionsList = json['sessions'] as List<dynamic>? ?? [];
    final sessions = _parseSessions(sessionsList, context.currentDate);

    // Parse warnings
    final warningsList = json['warnings'] as List<dynamic>? ?? [];
    final warnings = _parseWarnings(warningsList);

    // Parse recommended habits
    final habitsList = json['recommendedHabits'] as List<dynamic>? ?? [];
    final recommendedHabits = _parseRecommendedHabits(habitsList);

    // Calculate statistics
    final totalMinutes = sessions.fold<int>(
      0,
      (sum, s) => sum + s.duration.inMinutes,
    );
    final deepWorkBlocks = sessions
        .where((s) => s.type == SessionType.study && s.duration.inMinutes >= 90)
        .length;
    final breakCount =
        sessions.where((s) => s.type == SessionType.breakTime).length;

    return PlannerReasoning(
      sessions: sessions,
      reasoning: json['reasoning'] as String? ?? 'Schedule generated',
      orderRationale:
          json['orderRationale'] as String? ?? 'Sessions ordered by priority',
      recommendedHabits: recommendedHabits,
      warnings: warnings,
      totalScheduledMinutes: totalMinutes,
      deepWorkBlocks: deepWorkBlocks,
      breakCount: breakCount,
    );
  }

  List<PlannerSessionEntity> _parseSessions(
    List<dynamic> sessionsList,
    DateTime date,
  ) {
    final sessions = <PlannerSessionEntity>[];

    for (final item in sessionsList) {
      if (item is! Map<String, dynamic>) continue;

      final title = (item['title'] as String?)?.trim() ?? '';
      final startRaw = item['startTime'] as String?;
      final endRaw = item['endTime'] as String?;
      final typeRaw = item['type'] as String?;
      final reason = item['reason'] as String?;
      final energyRaw = item['energyLevel'] as String?;
      final priority = item['priority'] as int?;
      final linkedTaskId = item['linkedTaskId'] as String?;
      final linkedHabitId = item['linkedHabitId'] as String?;

      if (title.isEmpty || startRaw == null || endRaw == null) continue;

      final startTime = _parseTime(startRaw, date);
      final endTime = _parseTime(endRaw, date);
      if (startTime == null || endTime == null) continue;

      final duration = endTime.difference(startTime);
      if (duration.isNegative || duration.inMinutes == 0) continue;
      if (duration.inMinutes > 240) continue; // Max 4 hours per session

      final type = SessionType.values.firstWhere(
        (e) => e.name == typeRaw,
        orElse: () => SessionType.other,
      );

      final energyLevel = SessionEnergyLevel.values.firstWhere(
        (e) => e.name == energyRaw,
        orElse: () => SessionEnergyLevel.medium,
      );

      sessions.add(
        PlannerSessionEntity(
          id: const Uuid().v4(),
          title: title,
          startTime: startTime,
          endTime: endTime,
          type: type,
          completed: false,
          linkedTaskId:
              (linkedTaskId?.trim().isEmpty ?? true) ? null : linkedTaskId,
          linkedHabitId:
              (linkedHabitId?.trim().isEmpty ?? true) ? null : linkedHabitId,
          reason: reason,
          energyLevel: energyLevel,
          priority: priority,
        ),
      );
    }

    sessions.sort((a, b) => a.startTime.compareTo(b.startTime));
    return sessions;
  }

  List<ScheduleWarning> _parseWarnings(List<dynamic> warningsList) {
    final warnings = <ScheduleWarning>[];
    for (final item in warningsList) {
      if (item is! Map<String, dynamic>) continue;

      final message = item['message'] as String?;
      final severityRaw = item['severity'] as String?;
      final suggestion = item['suggestion'] as String?;

      if (message == null) continue;

      final severity = WarningSeverity.values.firstWhere(
        (e) => e.name == severityRaw,
        orElse: () => WarningSeverity.info,
      );

      warnings.add(
        ScheduleWarning(
          message: message,
          severity: severity,
          suggestion: suggestion,
        ),
      );
    }
    return warnings;
  }

  List<RecommendedHabit> _parseRecommendedHabits(List<dynamic> habitsList) {
    final habits = <RecommendedHabit>[];
    for (final item in habitsList) {
      if (item is! Map<String, dynamic>) continue;

      final title = item['title'] as String?;
      final reason = item['reason'] as String?;
      final current = item['currentBehavior'] as String?;
      final suggested = item['suggestedBehavior'] as String?;

      if (title == null || reason == null || current == null || suggested == null) {
        continue;
      }

      habits.add(
        RecommendedHabit(
          title: title,
          description: reason,
          reason: RecommendationReason.generalWellness,
          currentBehavior: current,
          suggestedBehavior: suggested,
          expectedBenefit: reason,
          priority: 5,
        ),
      );
    }
    return habits;
  }

  // ===========================================================================
  // STAGE 4: COMPREHENSIVE VALIDATION
  // ===========================================================================

  void _validateSessions(
    List<PlannerSessionEntity> sessions,
    PlannerContext context,
  ) {
    if (sessions.isEmpty) {
      throw const AiPlannerException(
        'Validation failed: No valid sessions generated.',
      );
    }

    // Check for overlaps
    for (var i = 0; i < sessions.length - 1; i++) {
      final current = sessions[i];
      final next = sessions[i + 1];

      if (current.endTime.isAfter(next.startTime)) {
        throw AiPlannerException(
          'Validation failed: "${current.title}" overlaps with "${next.title}".',
        );
      }
    }

    for (final session in sessions) {
      for (final block in context.busyTimeBlocks.where((b) => !b.isFlexible)) {
        if (session.startTime.isBefore(block.endTime) && session.endTime.isAfter(block.startTime)) {
          throw AiPlannerException('Validation failed: "${session.title}" overlaps calendar event "${block.title}".');
        }
      }
    }

    // Check total duration
    final totalMinutes = sessions.fold<int>(
      0,
      (sum, s) => sum + s.duration.inMinutes,
    );

    if (totalMinutes > 1440) {
      throw const AiPlannerException(
        'Validation failed: Total scheduled time exceeds 24 hours.',
      );
    }

    // Verify sleep session exists
    final hasSleep = sessions.any((s) => s.type == SessionType.sleep);
    if (!hasSleep) {
      throw const AiPlannerException(
        'Validation failed: No sleep session scheduled.',
      );
    }

    // Check for reasonable breaks
    var consecutiveFocusBlocks = 0;
    for (final session in sessions) {
      if (session.type == SessionType.study || session.type == SessionType.habit) {
        consecutiveFocusBlocks++;
        if (consecutiveFocusBlocks > 3) {
          throw AiPlannerException(
            'Validation failed: Too many consecutive focus blocks without breaks (${session.title}).',
          );
        }
      } else if (session.type == SessionType.breakTime) {
        consecutiveFocusBlocks = 0;
      }
    }

    // Validate task and habit linkage
    for (final session in sessions) {
      if (session.linkedTaskId != null) {
        final taskExists = context.tasks.any((t) => t.id == session.linkedTaskId);
        if (!taskExists) {
          throw AiPlannerException(
            'Validation failed: Session "${session.title}" linked to non-existent task.',
          );
        }
      }

      if (session.linkedHabitId != null) {
        final habitExists = context.habits.any((h) => h.id == session.linkedHabitId);
        if (!habitExists) {
          throw AiPlannerException(
            'Validation failed: Session "${session.title}" linked to non-existent habit.',
          );
        }
      }
    }
  }

  // ===========================================================================
  // STAGE 5: SCHEDULE OPTIMIZATION
  // ===========================================================================

  PlannerReasoning _optimizeSchedule(
    PlannerReasoning reasoning,
    PlannerContext context,
  ) {
    var sessions = reasoning.sessions;
    var warnings = List<ScheduleWarning>.from(reasoning.warnings);

    // Optimization 1: Ensure high-priority tasks are in high-energy windows
    sessions = _optimizeForEnergy(sessions, context);

    // Optimization 2: Group similar tasks together
    sessions = _groupSimilarTasks(sessions);

    // Optimization 3: Add missing meals if needed
    sessions = _ensureMeals(sessions, context);

    // Optimization 4: Generate additional warnings
    warnings.addAll(_generateOptimizationWarnings(sessions, context));

    return reasoning.copyWith(
      sessions: sessions,
      warnings: warnings,
    );
  }

  /// Optimizes task placement based on energy levels.
  List<PlannerSessionEntity> _optimizeForEnergy(
    List<PlannerSessionEntity> sessions,
    PlannerContext context,
  ) {
    // Morning hours (after wake + 1-4 hours) = high energy
    // Ensure complex/high-priority tasks are placed here

    // Sessions are already ordered by Gemini with energy optimization
    // This is a placeholder for future advanced re-ordering logic
    return sessions;
  }

  /// Groups similar tasks to reduce context switching.
  List<PlannerSessionEntity> _groupSimilarTasks(
    List<PlannerSessionEntity> sessions,
  ) {
    // Sessions are already ordered by Gemini with grouping consideration
    // This is a placeholder for future advanced grouping logic
    return sessions;
  }

  /// Ensures essential meals are scheduled.
  List<PlannerSessionEntity> _ensureMeals(
    List<PlannerSessionEntity> sessions,
    PlannerContext context,
  ) {
    final hasMeals = sessions.any((s) => s.type == SessionType.meal);
    if (hasMeals) {
      return sessions; // Gemini already added meals
    }

    // If no meals, this is a warning but not a blocker
    // Don't force-add meals as it might conflict with user preferences
    return sessions;
  }

  /// Generates additional warnings based on optimization analysis.
  List<ScheduleWarning> _generateOptimizationWarnings(
    List<PlannerSessionEntity> sessions,
    PlannerContext context,
  ) {
    final warnings = <ScheduleWarning>[];

    // Check sleep duration
    final sleepSession = sessions.firstWhere(
      (s) => s.type == SessionType.sleep,
      orElse: () => sessions.first,
    );

    if (sleepSession.type == SessionType.sleep) {
      final sleepHours = sleepSession.duration.inHours;
      if (sleepHours < 6) {
        warnings.add(
          ScheduleWarning(
            message: 'You only planned $sleepHours hours of sleep.',
            severity: WarningSeverity.critical,
            suggestion: 'Aim for 7-8 hours for optimal health and performance.',
          ),
        );
      }
    }

    // Check for overloaded periods
    final studySessions = sessions.where((s) => s.type == SessionType.study);
    final totalStudyMinutes = studySessions.fold<int>(
      0,
      (sum, s) => sum + s.duration.inMinutes,
    );

    if (totalStudyMinutes > 480) {
      // More than 8 hours of study
      warnings.add(
        ScheduleWarning(
          message: 'You have scheduled ${(totalStudyMinutes / 60).toStringAsFixed(1)} hours of study time.',
          severity: WarningSeverity.warning,
          suggestion: 'Consider breaking this across multiple days to avoid burnout.',
        ),
      );
    }

    // Check for missing breaks
    final breakCount = sessions.where((s) => s.type == SessionType.breakTime).length;
    final focusBlockCount = sessions
        .where((s) => s.type == SessionType.study || s.type == SessionType.habit)
        .length;

    if (focusBlockCount > 3 && breakCount < 2) {
      warnings.add(
        const ScheduleWarning(
          message: 'Not enough breaks between focus blocks.',
          severity: WarningSeverity.warning,
          suggestion: 'Add 10-15 minute breaks every 90 minutes for better focus.',
        ),
      );
    }

    // Check for urgent deadlines
    final urgentTasks = context.urgentTasks;
    final scheduledUrgentIds = sessions
        .where((s) => s.linkedTaskId != null)
        .map((s) => s.linkedTaskId)
        .toSet();

    final unscheduledUrgent = urgentTasks
        .where((t) => !scheduledUrgentIds.contains(t.id))
        .toList();

    if (unscheduledUrgent.isNotEmpty) {
      warnings.add(
        ScheduleWarning(
          message: '${unscheduledUrgent.length} urgent task(s) could not be scheduled today.',
          severity: WarningSeverity.critical,
          suggestion: 'These deadlines may be unrealistic given available time.',
        ),
      );
    }

    return warnings;
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  DateTime? _parseTime(String hhmm, DateTime date) {
    final parts = hhmm.trim().split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dt) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${weekdays[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}
