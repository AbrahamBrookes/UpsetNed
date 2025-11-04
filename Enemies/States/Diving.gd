extends State

## this is the enemy diving state, so there is no player interaction here.

var jump_power_left = 0.0
@export var max_jump_power: float = 1.0
@export var jump_decay_rate: float = 5.0
@export var jump_velocity: float = 5.0
@export var move_speed: float = 5.0

@export var mesh: Node3D

@export var look_at_target: Node3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	animation_override = "Diving"

func Enter(_extra_data = null):
	# toggle animation blend spaces for in-game pointy arms
	if state_machine.click_shoot:
		state_machine.click_shoot.sliding = true
	# Apply immediate upward impulse
	state_machine.locomotor.velocity.y = jump_velocity
	jump_power_left = max_jump_power
	# Update animation
	state_machine.anim_tree.set("parameters/Locomotion/Diving/blend_position", Vector2(1.0, 1.0))
	

func Physics_Update(delta: float):
	# Apply additional jump power while button held (optional)
	if jump_power_left > 0.0:
		jump_power_left -= jump_decay_rate * delta
		state_machine.locomotor.velocity.y += jump_power_left * delta
	else:
		jump_power_left = 0.0

	# Apply gravity
	state_machine.locomotor.velocity.y -= gravity * delta

	state_machine.locomotor.move_and_slide()
	

	# get the float speed for animation purposes
	var forward_speed = Vector2(
		state_machine.locomotor.velocity.x,
		state_machine.locomotor.velocity.z
	).length()

	# if we are moving, rotate the mesh to face movement direction or look at target
	if forward_speed > 0.1:
		var mesh_rotation = mesh.global_transform.basis.get_euler()
		mesh_rotation.y = atan2(state_machine.locomotor.velocity.x, state_machine.locomotor.velocity.z)
		mesh.rotation = mesh_rotation

	# our animation is using a Blendspace2D with 5 animations:
	# idle (0,0), strafe right (1,0), strafe left (-1,0), forward (0,1), backward (0,-1)
	# so we need to get the blend position based on the velocity vs the rotation of the mesh
	var local_velocity = mesh.global_transform.basis.inverse() * state_machine.locomotor.velocity
	var blend_position = Vector2(
		-local_velocity.x,  # invert X
		-local_velocity.z   # invert Z
	).normalized() * (forward_speed / move_speed)
	
	# Update animation
	state_machine.anim_tree.set("parameters/Locomotion/Locomote/blend_position", blend_position)
	
	# Check if landed (only after moving)
	if state_machine.locomotor.is_on_floor() and state_machine.locomotor.velocity.y <= 0.0:
		state_machine.TransitionTo("DiveSlide")
