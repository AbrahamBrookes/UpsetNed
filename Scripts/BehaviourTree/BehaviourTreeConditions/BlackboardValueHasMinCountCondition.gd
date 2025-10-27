extends BehaviourTreeCondition

class_name BlackboardValueHasMinCountCondition

## Given a key name, check it is an array with a count over min_count

@export var key_name: String = ""
@export var min_count: int = 1

func tick(blackboard: BehaviourTreeBlackboard) -> int:
	var value = blackboard.get_blackboard_value(key_name, [])

	# fail if not an array
	if typeof(value) != TYPE_ARRAY:
		return BehaviourTreeResult.Status.FAILURE

	# check if the array has enough elements
	if value.size() >= min_count:
		return BehaviourTreeResult.Status.SUCCESS
	
	return BehaviourTreeResult.Status.SUCCESS
