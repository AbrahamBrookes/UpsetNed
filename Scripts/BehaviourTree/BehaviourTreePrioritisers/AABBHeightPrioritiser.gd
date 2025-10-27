extends BehaviourTreePrioritiser

class_name AABBHeightPrioritiser

## Takes a list of targets, checks their physical height in world space and returns
## a list ordered by height (tallest to shortest).

# the name of the blackboard value to get
@export var blackboard_key: String = "targets"

func tick(blackboard: BehaviourTreeBlackboard) -> Array:
	var targets: Array = blackboard.get_blackboard_value(blackboard_key, [])
	if targets.size() > 0:
		var heights: Array = []
		for target in targets:
			# use AABB calculation to get the height of each target in world space
			var aabb: AABB = target.get_transformed_aabb()
			var height: float = aabb.size.y
			heights.append(height)
		# return the heights array ordered from tallest to shortest
		heights.sort_custom(HeightSort)
		return heights
	else:
		push_warning("AABBHeightPrioritiser: No targets found in blackboard!")
		return []

func HeightSort(a, b) -> int:
	return b - a  # Sort in descending order (tallest to shortest)
