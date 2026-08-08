import 'agent_head_type.dart';

/// Classified user intent routed by the orchestrator.
enum AgentIntent {
  recommendNow,
  generatePlan,
  simplifyPlan,
  fitIntoTime,
  chatCoaching,
  goalReview,
  habitAnalysis,
  journalInsight,
  knowledgeQuery,
  unknown,
}

extension AgentIntentX on AgentIntent {
  AgentHeadType get primaryHead => switch (this) {
        AgentIntent.recommendNow => AgentHeadType.chiefOfStaff,
        AgentIntent.generatePlan ||
        AgentIntent.simplifyPlan ||
        AgentIntent.fitIntoTime =>
          AgentHeadType.planner,
        AgentIntent.chatCoaching => AgentHeadType.coach,
        AgentIntent.goalReview => AgentHeadType.goalStrategist,
        AgentIntent.habitAnalysis => AgentHeadType.habitAnalyst,
        AgentIntent.journalInsight => AgentHeadType.journalAnalyst,
        AgentIntent.knowledgeQuery => AgentHeadType.knowledge,
        AgentIntent.unknown => AgentHeadType.chiefOfStaff,
      };
}
