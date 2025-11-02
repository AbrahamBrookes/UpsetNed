extends BehaviourTreeAction

class_name ReturnStatusAction

## Simply returns the status set in the editor

@export var status: BehaviourTreeResult.Status

func tick(_blackboard: BehaviourTreeBlackboard) -> int:
	return status
