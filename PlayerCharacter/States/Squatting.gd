extends State

@export var move_speed: float = 5.0

func Enter(_extra_data = null):
	# toggle animation blend spaces for in-game pointy arms
	if state_machine.click_shoot:
		state_machine.click_shoot.sliding = false
		
	# if our velocity is greater than something, slide instead
	var horizontal_velocity = Vector3(player_character.velocity.x, 0.0, player_character.velocity.z)
	if horizontal_velocity.length() > 0.1:
		animation_override = "Sliding"

func Physics_Update(_delta: float):
	# if our velocity is greater than something, slide instead
	var horizontal_velocity = Vector3(player_character.velocity.x, 0.0, player_character.velocity.z)
	if horizontal_velocity.length() > 0.1:
		state_machine.TransitionTo("Sliding")
		return
		
	# if the player releases squat, go back to locomote
	if not state_machine.input.current_input.squat:
		state_machine.TransitionTo("Locomote")
		return
