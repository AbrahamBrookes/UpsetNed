extends BehaviourTreeAction

## This class checks the state machine against a given array of states and
## if the state machine is in one of thise states this action will return
## RUNNING otherwise it will return you "else" value as set in the editor

class_name ReturnRunningWhenInStatesAction

@export var states: Array[String] = []

@export var else_type: BehaviourTreeResult.Status = BehaviourTreeResult.Status.SUCCESS

func _tick(_blackboard: BehaviourTreeBlackboard) -> int:
	if behaviour_tree.state_machine and behaviour_tree.state_machine.is_in_states(states):
		return BehaviourTreeResult.Status.RUNNING
	return else_type
