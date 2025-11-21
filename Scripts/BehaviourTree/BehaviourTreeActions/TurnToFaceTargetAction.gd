extends BehaviourTreeAction

class_name TurnToFaceTargetAction

## Pivot to face the given target

@export var blackboard_key: String = "current_target"

@export var node_to_rotate: Node3D

func _tick(blackboard: BehaviourTreeBlackboard) -> int:
	var target: Node3D = blackboard.get_blackboard_value(blackboard_key)
	
	if not "global_position" in target:
		push_error("Target does not have a global_position")
		return BehaviourTreeResult.Status.FAILURE
	
	if not node_to_rotate:
		push_error("must set node to rotate in behaviour tree turn to face target action")
		return BehaviourTreeResult.Status.FAILURE
	
	# turn the node to rotate to face the target, but only around the Y axis
	var from = node_to_rotate.global_transform.origin
	var to = target.global_transform.origin
	to.y = from.y  # Ignore vertical difference for yaw-only rotation
	var look_at_transform = node_to_rotate.global_transform.looking_at(to, Vector3.UP)
	node_to_rotate.global_transform = look_at_transform
	
	# return NOTHING so that we keep executing the tree
	return BehaviourTreeResult.Status.NOTHING
