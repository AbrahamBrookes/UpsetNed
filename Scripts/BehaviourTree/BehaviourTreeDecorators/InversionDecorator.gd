extends BehaviourTreeDecorator

class_name InversionDecorator

## Inverts the result of its child node.
## If the child returns SUCCESS, the decorator returns FAILURE.

var child_node: Node = null

@export var debug: bool = false

func _ready():
	# Ensure there is exactly one child node
	if get_child_count() != 1:
		push_error("InversionDecorator: Must have exactly one child node!")
	else:
		child_node = get_child(0)
		if not child_node.has_method("tick"):
			push_error("InversionDecorator: Child node does not have tick() method!")

func tick(blackboard: BehaviourTreeBlackboard) -> int:
	var result = _tick(blackboard)
	if debug and behaviour_tree.debug:
		print("PatrolAction: tick result: " + str(result))
	return result

func _tick(blackboard: BehaviourTreeBlackboard) -> int:
	# defend against some misconfiguration
	if child_node == null:
		return BehaviourTreeResult.Status.FAILURE

	var child_result = child_node.tick(blackboard)
	if child_result == BehaviourTreeResult.Status.SUCCESS:
		return BehaviourTreeResult.Status.FAILURE
		
	return BehaviourTreeResult.Status.SUCCESS
