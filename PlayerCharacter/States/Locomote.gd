extends State

@export var move_speed: float = 5.0

@export var mesh: Node3D

func Enter(_extra_data = null):
	# toggle animation blend spaces for in-game pointy arms
	if state_machine.click_shoot:
		state_machine.click_shoot.sliding = false
		
	# if we are landing and the player is holding squat
	# and we have lateral velocity, go to sliding
	if state_machine.previous_state:
		if state_machine.previous_state.name == "Jumping" or state_machine.previous_state.name == "StandingBackflip":
			if state_machine.input.current_input.squat:
				squat_or_slide()

func Physics_Update(_delta: float):
	if state_machine.input.current_input.squat:
		squat_or_slide()
		return
	
	if not state_machine.locomotor.grounded:
		state_machine.TransitionTo("Falling")
		return

	# Get input
	var input_direction = state_machine.input.current_input.move
	
	# only rotate the mesh when we're moving
	var mesh_rotation = mesh.global_transform.basis.get_euler()
	if input_direction != Vector2.ZERO:
		# in this state we want to rotate the mesh to the camera direction
		# copy the rotation of the camera pivot to the mesh, but only the y axis
		var camera_rotation = player_character.mouselook.camera_pivot.global_transform.basis.get_euler()
		mesh_rotation.y = camera_rotation.y
	intent.desired_rotation = mesh_rotation

	# Update animation
	state_machine.anim_tree.set("parameters/Locomotion/Locomote/blend_position", input_direction)

	# Handle horizontal movement
	var horizontal_input = Vector3(input_direction.x, 0.0, input_direction.y)
	var world_direction = global_transform.basis * horizontal_input
	
	world_direction.x = world_direction.x * move_speed
	world_direction.z = world_direction.z * move_speed

	# transform the velocity to be facing from the mesh, as it has ben rotated
	intent.desired_velocity = mesh.global_transform.basis * world_direction

	state_machine.set_movement_intent(intent)

# define the actions we can do from this state into other states

# if the player presses jump, jump
func jump(_data = null):
	state_machine.TransitionTo("Jumping")
	
# if the player presses dive, dive
func dive(_data = null):
	state_machine.TransitionTo("Diving")
	
# if the player presses slide, slide
func slide(_data = null):
	state_machine.TransitionTo("Sliding")
	
func squat_or_slide():
	var horizontal_velocity = Vector3(
		state_machine.locomotor.velocity.x,
		0.0,
		state_machine.locomotor.velocity.z
	)
	
	if horizontal_velocity.length() > 0.05:
		slide()
		return
	else:
		state_machine.TransitionTo("Squatting")
	
	
