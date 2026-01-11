extends State

## When a player jumos off a wall they do a badass flip. When they move the mouse we are using a
## blend space to blend them between a back flip or side flip (cartwheel).

var jump_power_left = 0.0
@export var max_jump_power: float = 1.0
@export var jump_decay_rate: float = 5.0
@export var jump_velocity: float = 5.5
@export var move_speed: float = 5.0

@export var mesh: Node3D

## must pass in the ray cast collision so we can get the wall normal
func Enter(extra_data: Vector3 = Vector3.BACK):
	# toggle animation blend spaces for in-game pointy arms
	if state_machine.click_shoot:
		state_machine.click_shoot.current_clickshoot_state = ClickShoot.ClickShootState.STANDING
	
	# apply wall flip impulse
	intent.desired_velocity = player_character.velocity + extra_data * jump_velocity

	# Apply immediate upward impulse
	intent.desired_velocity.y = jump_velocity
	
	# carry forward rotation
	intent.desired_rotation = player_character.mesh.rotation
	
	state_machine.set_movement_intent(intent)
	
	# reset jump power
	jump_power_left = max_jump_power
	

func Physics_Update(delta: float):
	
	if Input.is_action_just_pressed("dive"):
		dive()
		return
		
	# Apply additional jump power while button held (optional)
	if jump_power_left > 0.0:
		jump_power_left -= jump_decay_rate * delta
		intent.desired_velocity.y += jump_power_left * delta
	else:
		jump_power_left = 0.0
	
	state_machine.set_movement_intent(intent)
	
	if state_machine.locomotor.is_on_floor():
		land()
		return
	
func land() -> void:
	# if the player is holding crouch when they land, go to sliding
	if state_machine.input.current_input.squat:
		state_machine.TransitionTo("Sliding")
		return
		
	state_machine.TransitionTo("Locomote")

func dive(_data = null) -> void:
	# we can dive from a wallflip
	state_machine.TransitionTo("Diving")
