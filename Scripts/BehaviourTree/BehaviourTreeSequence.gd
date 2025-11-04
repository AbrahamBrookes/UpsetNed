extends Node

class_name BehaviourTreeSequence

## A BehaviourTreeSequence is a type of composite node in a behavior tree.
## It executes its child nodes in order, from top to bottom. Generally we
## will have conditions first, then actions. If any condition fails the
## sequence fails and stops executing further children. If all conditions
## are met, the actions are executed in order, resulting in an action.

# a reference that gets set by the behaviour tree on ready
var behaviour_tree: BehaviourTree

# Cache the tickable children of this node so we're not querying them every tick
var tickable_children: Array = []

# allow skipping of children via a "dont_tick" property on them
@export var dont_tick: bool = false

# if checked, will log the nodes name when it is ticked
@export var debug_log: bool = false

func _ready():
	tickable_children = []
	for child in get_children():
		if child.has_method("tick"):
			tickable_children.append(child)
		else:
			push_error("BehaviourTreeSelector: Child '%s' does not have tick() method!" % child.name)


## A wrapper for the tick function so we can print the node name when debugging
func tick(blackboard: BehaviourTreeBlackboard):

	var result = _tick(blackboard)
	if debug_log:
		print(self.name + " " + str(result))
		
	return result

func _tick(blackboard: BehaviourTreeBlackboard) -> int:
	for child in tickable_children:
		# the child might have a "dont_tick" property set to true
		if "dont_tick" in child and child.dont_tick:
			continue
		
		var result = child.tick(blackboard)
		match result:
			BehaviourTreeResult.Status.FAILURE:
				return BehaviourTreeResult.Status.FAILURE
			BehaviourTreeResult.Status.RUNNING:
				return BehaviourTreeResult.Status.RUNNING
			# SUCCESS: continue to next child
	
	# All children succeeded
	return BehaviourTreeResult.Status.SUCCESS
