extends Node

class_name BehaviourTreeCondition

## A BehaviourTreeCondition is a condition that must be met for the behavior
## tree to proceed. You can extend this class to create specific conditions,
## such as checking if an enemy is in range, if health is above a certain
## threshold, or if a specific item is available.

# a reference that gets set by the behaviour tree on ready
var behaviour_tree: BehaviourTree

func tick(_blackboard: BehaviourTreeBlackboard) -> int:
	# Override this method in subclasses to implement specific condition logic.
	# Return SUCCESS if the condition is met, otherwise return FAILURE.
	push_error("BehaviourTreeCondition: tick() not implemented!")
	return BehaviourTreeResult.Status.FAILURE
