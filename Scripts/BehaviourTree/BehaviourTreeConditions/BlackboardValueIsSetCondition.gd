extends BehaviourTreeCondition

class_name BlackboardValueIsSetCondition

## Given a key name, check it is set to a non-empty array

@export var key_name: String = "targets"

func tick(blackboard: BehaviourTreeBlackboard) -> int:
	var value = blackboard.get_blackboard_value(key_name, null)

	if not value:
		return BehaviourTreeResult.Status.FAILURE

	return BehaviourTreeResult.Status.SUCCESS
