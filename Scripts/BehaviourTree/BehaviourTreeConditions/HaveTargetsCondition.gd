extends BehaviourTreeCondition

class_name BlackboardValueHasMinCount

## Given a blackboard key name and a number, pull the key from the blackboard
## and if it is an array, check if it is over count
@export var blackboard_key: String
@export var min_count:int = 1

func tick(blackboard: BehaviourTreeBlackboard) -> int:
	var value = blackboard.get_blackboard_value(blackboard_key, [])

	if not value is Array:
		push_error("blackboard value is not an array")
		return BehaviourTreeResult.Status.FAILURE
		
	if not value.count() > min_count:
		return BehaviourTreeResult.Status.FAILURE
		
	return BehaviourTreeResult.Status.SUCCESS
	
	
	
