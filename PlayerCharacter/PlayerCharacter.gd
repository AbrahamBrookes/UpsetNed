extends CharacterBody3D
class_name DeterministicPlayerCharacter

# The DeterministicPlayerCharacter is a player controller script that is not physics-driven. Instead
# of using a RigidBody3D and applying forces, we are using a PlayerCharacter3D and driving movement
# using move_and_slide.

# since we are rotating the mesh separately we need a reference to it
@export var mesh: MeshInstance3D
# child scripts and the state machine require a reference to the anim tree
@export var animTree : AnimationTree
# the state machine is our custom rolled state manager
@export var stateMachine : StateMachine

# bundled player camera
@export var camera: Camera3D
@export var camera_target_offset: Vector3

# the mouselook component acts like a mixin
@export var mouselook: Mouselook

# the UI progress bar we are using for health
@export var ui_healthbar: ProgressBar

func _ready() -> void:
	if not mesh:
		print("not mesh")
	#stateMachine.TransitionTo("Prone")
	ui_healthbar.value = 100
	
func _physics_process(_delta):
	mouselook.mouseLook()

func receive_damage() -> void:
	ui_healthbar.value -= 3
	pass

# proxy the get_aabb down to our mesh
func get_aabb() -> AABB:
	return mesh.get_aabb()
