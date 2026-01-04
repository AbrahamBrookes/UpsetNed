extends State

@export var move_speed: float = 5.0

func Enter(_extra_data = null):
	# toggle animation blend spaces for in-game pointy arms
	if state_machine.click_shoot:
		state_machine.click_shoot.sliding = false

func Physics_Update(_delta: float):
	# if our velocity is greater than something, slide instead
	var horizontal_velocity = Vector3(player_character.velocity.x, 0.0, player_character.velocity.z)
	if horizontal_velocity.length() > 0.1:
		state_machine.TransitionTo("Sliding")
		return
		
	# if the player releases squat, go back to locomote
	if Input.is_action_just_released("squat"):
		state_machine.TransitionTo("Locomote")
		return
	
	if not player_character.is_on_floor():
		state_machine.TransitionTo("Falling")
		return

	# Get input
	#var input_direction = state_machine.input.current_input.move
#
	## Update animation
	#state_machine.anim_tree.set("parameters/Locomotion/Locomote/blend_position", input_direction)
#
	## Handle horizontal movement
	#var horizontal_input = Vector3(input_direction.x, 0.0, input_direction.y)
	#var world_direction = global_transform.basis * horizontal_input
	#
	#player_character.velocity.x = world_direction.x * move_speed
	#player_character.velocity.z = world_direction.z * move_speed
#
	#player_character.move_and_slide()
