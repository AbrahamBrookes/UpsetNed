extends BehaviourTreeEvaluator

class_name TargetHeightEvaluator

## Takes a target, checks its physical height in world space and returns
## its height in game units as the evaluation float.

# the name of the blackboard value to get
@export var blackboard_key: String = "current_target"

func evaluate(blackboard: BehaviourTreeBlackboard) -> float:
	var target: Node3D = blackboard.get_blackboard_value(blackboard_key, null)
	if target:
		# use AABB calculation to get the height of the target in world space
		var aabb: AABB = target.get_transformed_aabb()
		var height: float = aabb.size.y
		return height
	else:
		push_warning("TargetThreatLevelEvaluator: No target found in blackboard!")
		return 0.0
