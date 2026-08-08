/// Discrete capabilities invoked by agent heads.
enum AgentSkillId {
  recommendNow,
  generatePlan,
  simplifyPlan,
  fitIntoTime,
  chatCoaching,
  goalReview,
  habitAnalysis,
  journalInsight,
  knowledgeSearch,
}

extension AgentSkillIdX on AgentSkillId {
  String get label => switch (this) {
        AgentSkillId.recommendNow => 'Recommend Now',
        AgentSkillId.generatePlan => 'Generate Plan',
        AgentSkillId.simplifyPlan => 'Simplify Plan',
        AgentSkillId.fitIntoTime => 'Fit Into Time',
        AgentSkillId.chatCoaching => 'Chat Coaching',
        AgentSkillId.goalReview => 'Goal Review',
        AgentSkillId.habitAnalysis => 'Habit Analysis',
        AgentSkillId.journalInsight => 'Journal Insight',
        AgentSkillId.knowledgeSearch => 'Knowledge Search',
      };
}
