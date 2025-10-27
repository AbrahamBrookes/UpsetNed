extends Node

class_name BehaviourTreeDecorator

## A BehaviourTreeDecorator is a node that can modify the behavior of its child nodes.
## You can extend this class to create specific decorators, such as repeating a task,
## inverting a condition, or adding a cooldown to an action.

func tick(_blackboard: BehaviourTreeBlackboard) -> int:
	# Override this method in subclasses to implement specific decorator logic.
	# Return SUCCESS if the decorator allows the child to proceed, otherwise return FAILURE.
	push_error("BehaviourTreeDecorator: tick() not implemented!")
	return BehaviourTreeResult.Status.FAILURE
