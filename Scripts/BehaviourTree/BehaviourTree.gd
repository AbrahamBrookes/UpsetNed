extends Node
class_name BehaviourTree

## Main behavior tree that manages execution and blackboard.
## Add this to your enemy and build your tree structure as children.
## Note that this node should only have a single child node - usually a
## BehaviourTreeSelector with a fallback to idle action.

@export var blackboard: BehaviourTreeBlackboard
@export var anim_tree: AnimationTree
var playback: AnimationNodeStateMachinePlayback
var root_node: Node

# for turning off the whole tree
@export var enabled: bool = true

# debug if ya wanna
@export var debug: bool = false

func _ready():
	# if we don't have our required nodes throw a configuration error
	if not blackboard:
		push_error("BehaviourTree has no blackboard set!")
	if not anim_tree:
		push_error("BehaviourTree has no anim_tree set!")
		
	playback = anim_tree.get("parameters/Locomotion/playback")
	
	# Get the first child as root node
	if get_child_count() > 0:
		root_node = get_child(0)
	else:
		push_error("BehaviourTree: No root node found!")
		
	# traverse all child nodes and if they have a "ChangeState" signal, hook it
	# up to the state_machines TransitionTo method (name, extra data)
	var action_nodes = find_children("*", "BehaviourTreeAction")
	for node in action_nodes:
		if node.has_signal("ChangeState"):
			node.connect("ChangeState", change_animation)
	
	# traverse all children and give them a reference to self
	var children = find_children("*")
	for child in children:
		if 'behaviour_tree' in child:
			child.behaviour_tree = self
		if 'blackboard' in child:
			child.blackboard = self
	
func change_animation(animation_name: String):
	playback.travel(animation_name)

func _process(_delta):
	if not enabled:
		return
	
	# Execute the tree every frame
	if root_node and root_node.has_method("tick"):
		root_node.tick(blackboard)

## proxy through to blackboard
func set_blackboard_value(key: String, value: Variant):
	blackboard.set_blackboard_value(key, value)

func get_blackboard_value(key: String, default = null):
	return blackboard.get_blackboard_value(key, default)

## Manual tick (for testing or custom control)
func tick() -> int:
	if not enabled:
		return BehaviourTreeResult.Status.FAILURE
	if root_node and root_node.has_method("tick"):
		return root_node.tick(blackboard)
	return BehaviourTreeResult.Status.FAILURE
