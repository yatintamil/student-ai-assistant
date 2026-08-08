import '../../../features/planner/domain/entities/planner_context.dart';
import '../../../features/planner/domain/entities/planner_reasoning.dart';

/// Defines AI-assisted schedule generation operations with 5-stage architecture.
///
/// The service acts as a reasoning engine that:
/// 1. Accepts a consolidated [PlannerContext] (never directly accesses repos)
/// 2. Builds structured prompts explaining the user's life
/// 3. Calls Gemini to reason and generate schedule
/// 4. Validates the output comprehensively
/// 5. Optimizes the schedule for user preferences
///
/// Returns [PlannerReasoning] containing sessions, explanations, warnings,
/// and habit recommendations.
abstract class AiPlannerService {
  /// Generates a full day schedule with reasoning from consolidated context.
  ///
  /// Stage 1: Context is pre-built by the controller
  /// Stage 2: Service builds a structured prompt
  /// Stage 3: Gemini reasons and generates schedule
  /// Stage 4: Comprehensive validation
  /// Stage 5: Schedule optimization
  ///
  /// Returns [PlannerReasoning] containing the schedule, reasoning,
  /// recommendations, and warnings.
  Future<PlannerReasoning> generatePlanWithReasoning({
    required PlannerContext context,
  });

  /// Simplifies an existing plan while preserving reasoning.
  ///
  /// Used to condense an overcrowded schedule or merge small fragments.
  /// Returns updated reasoning with simplified sessions.
  Future<PlannerReasoning> simplifyPlanWithReasoning({
    required PlannerContext context,
    required PlannerReasoning currentPlan,
  });

  /// Fits tasks and habits into a specific time window with reasoning.
  ///
  /// Used for "quick schedule" scenarios when the user has limited time.
  /// Returns reasoning explaining how items were prioritized and compressed.
  Future<PlannerReasoning> fitIntoAvailableTimeWithReasoning({
    required PlannerContext context,
  });
}

/// Exception thrown when AI planning operations fail.
class AiPlannerException implements Exception {
  /// Creates an AI planner exception with [message].
  const AiPlannerException(this.message);

  /// The error message.
  final String message;

  @override
  String toString() => 'AiPlannerException: $message';
}
