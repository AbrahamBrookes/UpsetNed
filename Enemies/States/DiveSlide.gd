extends State

# how much slide power we have left
@export var slide_force: float = 0.0
@export var slide_decay: float = 5.0

# how much boost we give the player on the slide
@export var slide_boost: float = 1.5
@export var move_speed: float = 5.0

@export var mesh: Node3D

func _ready():
	animation_override = "Diving"

func Enter(_extra_data = null):
	# toggle animation blend spaces for in-game pointy arms
	if state_machine.click_shoot:
		state_machine.click_shoot.sliding = true
	# set initial slide force based on current horizontal speed
	var horizontal_velocity = Vector3(state_machine.locomotor.velocity.x, 0.0, state_machine.locomotor.velocity.z)
	slide_force = horizontal_velocity.length() * slide_boost  # multiplier for slide power
	# rotate the mesh to the velocity when we enter the slide
	if horizontal_velocity.length() > 0.1:
		var mesh_rotation = mesh.global_transform.basis.get_euler()
		mesh_rotation.y = atan2(horizontal_velocity.x, horizontal_velocity.z)
		mesh.rotation = mesh_rotation
	

func Physics_Update(delta: float):
	# if slide force is less than the threshold, back to locomote
	if slide_force < 0.01:
		state_machine.TransitionTo("Idle")
		return
	
	# get the float speed for animation purposes
	var forward_speed = Vector2(
		state_machine.locomotor.velocity.x,
		state_machine.locomotor.velocity.z
	).length()
	
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


	# Apply slide force
	state_machine.locomotor.velocity.x = slide_force * state_machine.locomotor.velocity.normalized().x
	state_machine.locomotor.velocity.z = slide_force * state_machine.locomotor.velocity.normalized().z
	state_machine.locomotor.move_and_slide()

	# Decrease slide force over time
	slide_force -= slide_decay * delta  # arbitrary slide decay rate
