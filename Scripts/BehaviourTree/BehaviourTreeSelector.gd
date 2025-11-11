extends Node

class_name BehaviourTreeSelector

## A BehaviourTreeSelector node will execute its children in order until one of them returns SUCCESS.
## If a child returns SUCCESS, the selector returns SUCCESS.
## If all children return FAILURE, the selector returns FAILURE.
## If a child returns RUNNING, the selector returns RUNNING stops executing that tick

# a reference that gets set by the behaviour tree on ready
var behaviour_tree: BehaviourTree

# Cache the tickable children of this node so we're not querying them every tick
var tickable_children: Array = []

# if checked, will log the nodes name when it is ticked
@export var debug_log: bool = false

# allow skipping of children via a "dont_tick" property on them
@export var dont_tick: bool = false

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
	if debug_log and behaviour_tree.debug:
		print(self.name + " " + str(result))
		
	return result

func _tick(blackboard: BehaviourTreeBlackboard) -> int:
	for child in tickable_children:

		# the child might have a "dont_tick" property set to true
		if "dont_tick" in child and child.dont_tick:
			continue

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
