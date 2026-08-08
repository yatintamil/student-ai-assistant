/// Specialized agent heads in the multi-head Life OS architecture.
enum AgentHeadType {
  /// Routes intent, synthesizes cross-domain recommendations.
  chiefOfStaff,

  /// Daily schedule generation, simplification, and time-fitting.
  planner,

  /// Conversational coaching and general life advice.
  coach,

  /// Goal hierarchy, progress, and alignment analysis.
  goalStrategist,

  /// Habit streaks, patterns, and improvement suggestions.
  habitAnalyst,

  /// Mood, energy, and reflection insights.
  journalAnalyst,

  /// Notes and knowledge retrieval (RAG-ready).
  knowledge,
}

extension AgentHeadTypeX on AgentHeadType {
  String get label => switch (this) {
        AgentHeadType.chiefOfStaff => 'Chief of Staff',
        AgentHeadType.planner => 'Planner',
        AgentHeadType.coach => 'Coach',
        AgentHeadType.goalStrategist => 'Goal Strategist',
        AgentHeadType.habitAnalyst => 'Habit Analyst',
        AgentHeadType.journalAnalyst => 'Journal Analyst',
        AgentHeadType.knowledge => 'Knowledge',
      };
}
