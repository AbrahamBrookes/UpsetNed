extends BehaviourTreeEvaluator

class_name DistanceToTargetEvaluator

## Takes a target, checks its physical distance to us and returns it
## as a float

# the name of the blackboard value to get
@export var blackboard_key: String = "current_target"

func evaluate(blackboard: BehaviourTreeBlackboard) -> float:
	var target: Node3D = blackboard.get_blackboard_value(blackboard_key, null)
	
	if not target:
		push_warning("DistanceToTargetEvaluator: No target found in blackboard!")
		return 0.0
	
	if not target is Node3D:
		push_warning("DistanceToTargetEvaluator: Target is not a Node3D!")
		return 0.0
	
	var thinker: Node3D = get_owner() as Node3D
	if not thinker:
		push_warning("DistanceToTargetEvaluator: BehaviourTreeEvaluator has no Node3D owner!")
		return 0.0

	var distance: float = thinker.global_transform.origin.distance_to(target.global_transform.origin)
	return distance
