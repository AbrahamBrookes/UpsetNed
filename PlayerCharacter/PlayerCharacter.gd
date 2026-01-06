extends CharacterBody3D
class_name DeterministicPlayerCharacter

# The DeterministicPlayerCharacter is a player controller script that is not physics-driven. Instead
# of using a RigidBody3D and applying forces, we are using a PlayerCharacter3D and driving movement
# using move_and_slide.

# a signal to emit when we land ater being airborne, to separate physics concerns
# out of our state machine logic
signal landed

# since we are rotating the mesh separately we need a reference to it
@export var mesh: Node3D
# child scripts and the state machine require a reference to the anim tree
@export var anim_tree : AnimationTree
# the state machine is our custom rolled state manager
@export var state_machine : StateMachine

# bundled player camera
@export var camera: Camera3D
@export var camera_target_offset: Vector3

# the mouselook component controls moving the camera with the mouse
@export var mouselook: Mouselook

# the UI progress bar we are using for health
@export var ui_healthbar: ProgressBar

# a reference to the input synchronizer
@export var input_synchronizer: InputSynchronizer

# we're letting the server decide if we are grounded instead of using is_on_floor()
# and using coyote time for being grounded so we can avoid floor jitters from server ticks
var grounded: bool = false
var grounded_coyote_time: int = 2
# and tracking if we were airborne last tick to handle landing
var was_airborne_last_tick: bool = false

# grab gravity once
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# calculate standard physics tick once
var physics_delta: float = 1.0 / Engine.physics_ticks_per_second

# gravity factor will never change so precompute it
var gravity_factor = gravity * physics_delta

func _ready() -> void:
	if not mesh:
		print("not mesh")
	ui_healthbar.value = 100
	
func _physics_process(_delta):
	mouselook.mouseLook()

func receive_damage() -> void:
	ui_healthbar.value -= 3
	pass

# proxy the get_aabb down to our mesh
func get_aabb() -> AABB:
	return mesh.get_aabb()

func _on_state_machine_intend_to_move(intent: MovementIntent) -> void:
	# if the intent intends to factor in gravity, do it here AND NOWHERE ELSE
	if intent.apply_gravity:
		intent.desired_velocity.y -= gravity_factor

	# apply the incoming intent
	velocity = intent.desired_velocity
	
	# rotate the mesh, not the whole object because of camera movement
	mesh.rotation = intent.desired_rotation
	
	# for landing detection, below
	var was_airborne: bool = not grounded
	
	move_and_slide()
		
	if is_on_floor():
		grounded = true
		grounded_coyote_time = 2
		if was_airborne:
			emit_signal("landed")
	else:
		grounded_coyote_time -= 1
		if grounded_coyote_time <= 0:
			grounded = false
