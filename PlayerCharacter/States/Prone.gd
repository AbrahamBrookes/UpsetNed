extends State

func Physics_Update(_delta: float):
	# if the player isn't holding squat, back to locomote
	if not Input.is_action_pressed("squat"):
		state_machine.TransitionTo("Locomote")
		return
	
	if not player_character.is_on_floor():
		state_machine.TransitionTo("Falling")
		return
