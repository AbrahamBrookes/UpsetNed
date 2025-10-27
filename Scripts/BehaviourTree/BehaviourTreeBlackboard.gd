extends Node

class_name BehaviourTreeBlackboard

## The BehaviourTreeBlackboard is a data store for behaviour trees with regards
## to an NPC or any decision making structure. It's just a dictionary with some
## accessors and it acts as the single datastore for an NPC's decision making

@export var data: Dictionary = {}

# a reference to the AnimationTree we are interacting with
@export var anim_tree: AnimationTree

# if we have no state machine assigned, warn on ready
func _ready():
	if not anim_tree:
		push_warning("BehaviourTreeBlackboard: No anim_tree assigned!")

## Helper methods
func set_blackboard_value(key: String, value: Variant):
	data[key] = value

func get_blackboard_value(key: String, default = null):
	return data.get(key, default)
