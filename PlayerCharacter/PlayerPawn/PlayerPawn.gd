extends Node3D

## The PlayerPawn is just the doll body for moving a character visually around
## the map. It has no collision and no logic, it is purely a puppet on strings
## being towed around the map by the server
class_name PlayerPawn

# since we are rotating the mesh separately we need a reference to it
@export var mesh: Node3D
# the animation player, for direct fenagling
@export var animation_player: AnimationPlayer
# child scripts and the state machine require a reference to the anim tree
@export var anim_tree : AnimationTree
# playback is the engine-level animation tree state machine
var playback: AnimationNodeStateMachinePlayback

@export var current_state: StringName

func _ready():
	playback = anim_tree.get("parameters/Locomotion/playback")
	set_current_state("Locomote")

func set_current_state(state_name: StringName):
	if playback:
		playback.travel(state_name)
		current_state = state_name
