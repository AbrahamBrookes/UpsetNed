extends State

@export var move_speed: float = 5.0

func Enter(_extra_data = null):
	# toggle animation blend spaces for in-game pointy arms
	if state_machine.click_shoot:
		state_machine.click_shoot.current_clickshoot_state = ClickShoot.ClickShootState.STANDING

func Physics_Update(_delta: float):
	# if the player releases squat, go back to locomote
	if not state_machine.input.current_input.squat:
		state_machine.TransitionTo("Locomote")
		return
		
	
	if not state_machine.locomotor.is_on_floor():
		state_machine.TransitionTo("Falling")
		return
		
func jump(_data = null):
	state_machine.TransitionTo("StandingBackflip")
	
