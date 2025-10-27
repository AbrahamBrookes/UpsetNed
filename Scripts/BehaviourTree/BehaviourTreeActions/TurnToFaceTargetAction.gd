extends BehaviourTreeAction

class_name TurnToFaceTargetAction

## Pivot to face the given target

@export var blackboard_key: String = "current_target"

@export var node_to_rotate: Node3D

func tick(blackboard: BehaviourTreeBlackboard):
	var target: Node3D = blackboard.get_blackboard_value(blackboard_key)
	print('sdf')
	if not target.has_property("global_position"):
		push_error("Target does not have a global_position")
		return BehaviourTreeResult.Status.FAILURE
	
	if not node_to_rotate:
		push_error("must set node to rotate in behaviour tree turn to face target action")
		return BehaviourTreeResult.Status.FAILURE
	
	# turn the node to rotate to face the target
	var look_at_transform = node_to_rotate.global_transform.looking_at(target.global_transform.origin, Vector3.UP)
	node_to_rotate.global_transform = look_at_transform
	
	return BehaviourTreeResult.Status.SUCCESS
	
