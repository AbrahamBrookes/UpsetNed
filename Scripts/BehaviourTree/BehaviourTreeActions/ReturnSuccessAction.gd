extends BehaviourTreeAction

class_name ReturnSuccessAction

## returns SUCCESS and does nothing else, as a terminator of a branch

func tick(_blackboard: BehaviourTreeBlackboard):
	return BehaviourTreeResult.Status.SUCCESS
