extends BehaviourTreeCondition

class_name BlackboardValueIsSetCondition

## Given a key name, check it is set to a non-empty array

@export var key_name: String = "targets"

@export var debug: bool = false

func _tick(blackboard: BehaviourTreeBlackboard) -> int:
	var value = blackboard.get_blackboard_value(key_name, null)
	
	if debug and behaviour_tree.debug:
		print("blackboard value " + key_name + " is: " + str(value))

	if not value:
		return BehaviourTreeResult.Status.FAILURE

	return BehaviourTreeResult.Status.SUCCESS
