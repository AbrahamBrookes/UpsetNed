extends State

func _ready():
	animation_override = "Sliding"

func Enter(_extra_data = null):
	# toggle animation blend spaces for in-game pointy arms
	if state_machine.click_shoot:
		state_machine.click_shoot.sliding = true

func Physics_Update(_delta: float):
	# if the player isn't holding squat, back to locomote
	if not Input.is_action_pressed("squat"):
		state_machine.TransitionTo("Locomote")
		return
	
	if not player_character.is_on_floor():
		state_machine.TransitionTo("Falling")
		return
