extends BehaviourTreeAction

class_name GoToStateAction

## Given a state, this action will flip to it once it is reached in the tree

@export var state_name: String = "Idle"

func _tick(_blackboard: BehaviourTreeBlackboard):
	# emit our ChangeState signal with the given name - we assume no extra_data to pass
	if debug_log:
		var old_state: String = behaviour_tree.state_machine.current_state.name
		print("Go To State Action: " + old_state + " -> " + state_name)
		
	ChangeState.emit(state_name)
	return BehaviourTreeResult.Status.SUCCESS
