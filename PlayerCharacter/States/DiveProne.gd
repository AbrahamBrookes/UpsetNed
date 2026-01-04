extends State

func _ready():
	animation_override = "Diving"

func Enter(_extra_data = null):
	# toggle animation blend spaces for in-game pointy arms
	if state_machine.click_shoot:
		state_machine.click_shoot.sliding = true
	
func Physics_Update(_delta: float):
	# if the player isn't holding dive, back to locomote
	if not Input.is_action_pressed("dive"):
		state_machine.TransitionTo("Locomote")
		return
	
	if not player_character.grounded:
		state_machine.TransitionTo("Falling")
		return
