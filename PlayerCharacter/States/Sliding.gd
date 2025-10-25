extends State

# how much slide power we have left
@export var slide_force: float = 0.0
@export var slide_decay: float = 5.0

func Enter(_extra_data = null):
	# set initial slide force based on current horizontal speed
	var horizontal_velocity = Vector3(player_character.velocity.x, 0.0, player_character.velocity.z)
	slide_force = horizontal_velocity.length() * 2.0  # arbitrary multiplier for slide power
	print("slide force", slide_force)

func Physics_Update(delta: float):
	# if slide force is less than the threshold, back to locomote
	if slide_force < 1.0:
		state_machine.TransitionTo("Prone")
		return

	# if the player isn't holding squat, back to locomote
	if not Input.is_action_pressed("squat"):
		state_machine.TransitionTo("Locomote")
		return
	
	if not player_character.is_on_floor():
		state_machine.TransitionTo("Falling")
		return

	# Apply slide force
	player_character.velocity.x = slide_force * player_character.velocity.normalized().x
	player_character.velocity.z = slide_force * player_character.velocity.normalized().z
	player_character.move_and_slide()

	# Decrease slide force over time
	slide_force -= slide_decay * delta  # arbitrary slide decay rate
