extends BehaviourTreeDecorator

class_name ResultTransformDecorator

## You give this node a "from" and a "to". If it ever gets a status matching
## your "from", it will return the "to" instead. Otherwise it passes the value
## right on through

@export var from_type: BehaviourTreeResult.Status
@export var to_type: BehaviourTreeResult.Status

var child_node: Node = null

# if checked, will log the nodes name when it is ticked
@export var debug_log: bool = false

func _ready():
	# Ensure there is exactly one child node
	if get_child_count() != 1:
		push_error("ResultTransformDecorator: Must have exactly one child node!")
	else:
		child_node = get_child(0)
		if not child_node.has_method("tick"):
			push_error("ResultTransformDecorator: Child node does not have tick() method!")


## A wrapper for the tick function so we can print the node name when debugging
func tick(blackboard: BehaviourTreeBlackboard):

	var result = _tick(blackboard)
	if debug_log and behaviour_tree.debug:
		print(self.name + " " + str(result))
		
	return result

func _tick(blackboard: BehaviourTreeBlackboard) -> int:
	# defend against some misconfiguration
	if child_node == null:
		return BehaviourTreeResult.Status.FAILURE

	var child_result = child_node.tick(blackboard)
	if child_result == from_type:
		return to_type
		
	return child_result
