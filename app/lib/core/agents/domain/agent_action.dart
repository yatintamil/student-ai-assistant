import 'package:equatable/equatable.dart';

/// Side effects the orchestrator executes after an agent response.
enum AgentActionType {
  none,
  regeneratePlan,
  simplifyPlan,
  fitIntoTime,
}

class AgentAction extends Equatable {
  const AgentAction({
    required this.type,
    this.availableMinutes,
  });

  const AgentAction.none() : this(type: AgentActionType.none);

  const AgentAction.regeneratePlan()
      : this(type: AgentActionType.regeneratePlan);

  const AgentAction.simplifyPlan() : this(type: AgentActionType.simplifyPlan);

  const AgentAction.fitIntoTime({required int minutes})
      : this(type: AgentActionType.fitIntoTime, availableMinutes: minutes);

  final AgentActionType type;
  final int? availableMinutes;

  @override
  List<Object?> get props => [type, availableMinutes];
}
