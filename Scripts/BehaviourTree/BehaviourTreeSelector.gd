extends Node

class_name BehaviourTreeSelector

## A BehaviourTreeSelector node will execute its children in order until one of them returns SUCCESS.
## If a child returns SUCCESS, the selector returns SUCCESS.
## If all children return FAILURE, the selector returns FAILURE.
## If a child returns RUNNING, the selector returns RUNNING and will resume from that child
## on the next tick.

# a reference that gets set by the behaviour tree on ready
var behaviour_tree: BehaviourTree

# Cache the tickable children of this node so we're not querying them every tick
var tickable_children: Array = []

func _ready():
	tickable_children = []
	for child in get_children():
		if child.has_method("tick"):
			tickable_children.append(child)
		else:
			push_error("BehaviourTreeSelector: Child '%s' does not have tick() method!" % child.name)

func tick(blackboard: BehaviourTreeBlackboard) -> int:
	for child in tickable_children:
		var result = child.tick(blackboard)
			
		match result:
			# if the child reports success then we stop and return to parent
			BehaviourTreeResult.Status.SUCCESS:
				return BehaviourTreeResult.Status.SUCCESS
			# if the child reports running then we stop and return running
			BehaviourTreeResult.Status.RUNNING:
				return BehaviourTreeResult.Status.RUNNING
			# FAILURE: continue to next child

	# All children failed
	return BehaviourTreeResult.Status.FAILURE
