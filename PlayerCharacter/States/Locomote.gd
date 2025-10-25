extends State

@export var move_speed: float = 5.0

@export var mesh: Node3D

func Physics_Update(_delta: float):
	# if the previous state was jumping and the player is holding squat
	# and we have lateral velocity, go to sliding
	if state_machine.previous_state and state_machine.previous_state.name == "Jumping":
		if Input.is_action_pressed("squat"):
			var horizontal_velocity = Vector3(player_character.velocity.x, 0.0, player_character.velocity.z)
			if horizontal_velocity.length() > 0.1:
				state_machine.TransitionTo("Sliding")
				return
				
	# if the player presses squat, squat
	if Input.is_action_just_pressed("squat"):
		state_machine.TransitionTo("Squatting")
		return
		
	# if the player presses jump, jump
	if Input.is_action_just_pressed("jump"):
		state_machine.TransitionTo("Jumping")
		return
	
	if not player_character.is_on_floor():
		state_machine.TransitionTo("Falling")
		return


	# Get input
	var input_direction = Vector2(
		Input.get_action_strength("run_l") - Input.get_action_strength("run_r"),
		Input.get_action_strength("run_f") - Input.get_action_strength("run_b")
	)
	
	# only rotate the mesh whn we're moving
	if input_direction != Vector2.ZERO:
		# in this state we want to rotate the mesh to the camera direction
		# copy the rotation of the camera pivot to the mesh, but only the y axis
		var camera_rotation = player_character.mouselook.camera_pivot.global_transform.basis.get_euler()
		var mesh_rotation = mesh.global_transform.basis.get_euler()
		mesh_rotation.y = camera_rotation.y
		mesh.rotation = mesh_rotation

	# Update animation
	state_machine.anim_tree.set("parameters/Locomotion/Locomote/blend_position", input_direction)

	# Handle horizontal movement
	var horizontal_input = Vector3(input_direction.x, 0.0, input_direction.y)
	var world_direction = global_transform.basis * horizontal_input
	
	world_direction.x = world_direction.x * move_speed
	world_direction.z = world_direction.z * move_speed

	# transform the velocity to be facing from the mesh, as it has ben rotated
	player_character.velocity = mesh.global_transform.basis * world_direction

	player_character.move_and_slide()
