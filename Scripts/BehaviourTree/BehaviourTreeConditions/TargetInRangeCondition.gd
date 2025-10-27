extends BehaviourTreeCondition

class_name TargetInRangeCondition

@export var blackboard_key: String = 'current_target'

@export var range_distance: float = 100.0

# cache the owner as it won't change
@export var thinker: Node3D

func tick(blackboard: BehaviourTreeBlackboard) -> BehaviourTreeResult.Status:
	var player: Node3D = blackboard.get_blackboard_value(blackboard_key, null)
	if not thinker:
		thinker = owner

	if not player or not thinker:
		return BehaviourTreeResult.Status.FAILURE

	var distance = thinker.global_position.distance_squared_to(player.global_position)
	if distance <= range_distance * range_distance:
		return BehaviourTreeResult.Status.SUCCESS
	return BehaviourTreeResult.Status.FAILURE
