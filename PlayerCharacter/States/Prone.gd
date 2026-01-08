extends State

func _ready():
	animation_override = "Sliding"

func Enter(_extra_data = null):
	# toggle animation blend spaces for in-game pointy arms
	if state_machine.click_shoot:
		state_machine.click_shoot.current_clickshoot_state = ClickShoot.ClickShootState.SLIDING

func Physics_Update(_delta: float):
	# if the player isn't holding squat, back to locomote
	if not state_machine.input.current_input.squat:
		state_machine.TransitionTo("Locomote")
		return
