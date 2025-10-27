extends CharacterBody3D


# since we are rotating the mesh separately we need a reference to it
@export var mesh: Node3D
# child scripts and the state machine require a reference to the anim tree
@export var anim_tree : AnimationTree
# the behaviour tree is our NPC brain system
@export var behaviour_tree : BehaviourTree
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	# Set physics process priority to run last
	process_physics_priority = 100  # Higher numbers run later

func _physics_process(delta: float) -> void:
	# This will run after other scripts due to higher priority
	# apply gravity every frame
	velocity.y -= gravity * delta
	move_and_slide()
