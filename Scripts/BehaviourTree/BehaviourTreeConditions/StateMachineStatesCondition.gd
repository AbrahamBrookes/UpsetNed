extends BehaviourTreeCondition

class_name StateMachineStatesCondition

# This condition checks if the state machine is in one of the specified states
# and if so returns success, otherwise failure.

@export var states: Array[String] = []

func _tick(_blackboard: BehaviourTreeBlackboard) -> int:
	if debug_log:
		print("Current state is " + behaviour_tree.state_machine.current_state.name)
	if behaviour_tree.state_machine and behaviour_tree.state_machine.is_in_states(states):
		return BehaviourTreeResult.Status.SUCCESS
	return BehaviourTreeResult.Status.FAILURE
