extends Node

class_name BehaviourTreePrioritiser

## Base class for you to extend and create your own more germaine prioritisation
## logic. BehaviourTreePrioritisers are ticked and return an ordered list up to
## the caller. Generally that caller will be a BehaviourTreePriorityDecorator.
## BehaviourTreePriorityDecorators are given an index and they select that index
## from the returned list and save it to a blackboard value, or return faliure

# a reference that gets set by the behaviour tree on ready
var behaviour_tree: BehaviourTree

func tick(_blackboard: BehaviourTreeBlackboard) -> Array:
	# Override this method in subclasses to implement specific prioritisation logic.
	# Return an ordered Array of evaluator names or IDs based on the blackboard input.
	push_error("BehaviourTreePrioritiser: tick() not implemented!")
	return []
