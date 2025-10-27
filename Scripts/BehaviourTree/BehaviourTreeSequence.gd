extends Node

class_name BehaviourTreeSequence

## A BehaviourTreeSequence is a type of composite node in a behavior tree.
## It executes its child nodes in order, from top to bottom. Generally we
## will have conditions first, then actions. If any condition fails the
## sequence fails and stops executing further children. If all conditions
## are met, the actions are executed in order, resulting in an action.

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
			BehaviourTreeResult.Status.FAILURE:
				return BehaviourTreeResult.Status.FAILURE
			BehaviourTreeResult.Status.RUNNING:
				return BehaviourTreeResult.Status.RUNNING
			# SUCCESS: continue to next child
	
	# All children succeeded
	return BehaviourTreeResult.Status.SUCCESS
