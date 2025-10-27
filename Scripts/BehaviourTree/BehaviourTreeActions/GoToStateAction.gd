extends BehaviourTreeAction

class_name GoToStateAction

## Given a state, this action will flip to it once it is reached in the tree

@export var state_name: String = "Idle"

func tick(_blackboard: BehaviourTreeBlackboard):
	# emit our ChangeState signal with the given name - we assume no extra_data to pass
	ChangeState.emit(state_name)
	return BehaviourTreeResult.Status.SUCCESS
