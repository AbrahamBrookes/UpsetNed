extends Node

class_name BehaviourTreeCondition

## A BehaviourTreeCondition is a condition that must be met for the behavior
## tree to proceed. You can extend this class to create specific conditions,
## such as checking if an enemy is in range, if health is above a certain
## threshold, or if a specific item is available.

# a reference that gets set by the behaviour tree on ready
var behaviour_tree: BehaviourTree

# if checked, will log the nodes name when it is ticked
@export var debug_log: bool = false

# allow skipping of children via a "dont_tick" property on them
@export var dont_tick: bool = false

## A wrapper for the tick function so we can print the node name when debugging
func tick(blackboard: BehaviourTreeBlackboard):

	var result = _tick(blackboard)
	if debug_log and behaviour_tree.debug:
		print(self.name + " " + str(result))
		
	return result

func _tick(_blackboard: BehaviourTreeBlackboard) -> int:
	# Override this method in subclasses to implement specific condition logic.
	# Return SUCCESS if the condition is met, otherwise return FAILURE.
	push_error("BehaviourTreeCondition: tick() not implemented!")
	return BehaviourTreeResult.Status.FAILURE
