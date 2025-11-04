extends Node

class_name BehaviourTreeDecorator

## A BehaviourTreeDecorator is a node that can modify the behavior of its child nodes.
## You can extend this class to create specific decorators, such as repeating a task,
## inverting a condition, or adding a cooldown to an action.

# a reference that gets set by the behaviour tree on ready
var behaviour_tree: BehaviourTree

# allow skipping of children via a "dont_tick" property on them
@export var dont_tick: bool = false

func tick(_blackboard: BehaviourTreeBlackboard) -> int:
	# Override this method in subclasses to implement specific decorator logic.
	# Return SUCCESS if the decorator allows the child to proceed, otherwise return FAILURE.
	push_error("BehaviourTreeDecorator: tick() not implemented!")
	return BehaviourTreeResult.Status.FAILURE
