extends CharacterBody3D


# since we are rotating the mesh separately we need a reference to it
@export var mesh: Node3D
# child scripts and the state machine require a reference to the anim tree
@export var anim_tree : AnimationTree
# the behaviour tree is our NPC brain system
@export var behaviour_tree : BehaviourTree

func _ready():
	# Set physics process priority to run last
	process_physics_priority = 100  # Higher numbers run later
