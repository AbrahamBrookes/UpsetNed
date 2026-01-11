extends State

var jump_power_left = 0.0
@export var max_jump_power: float = 1.0
@export var jump_decay_rate: float = 5.0
@export var jump_velocity: float = 5.0
@export var move_speed: float = 5.0

func Enter(_extra_data = null):
	# toggle animation blend spaces for in-game pointy arms
	if state_machine.click_shoot:
		state_machine.click_shoot.current_clickshoot_state = ClickShoot.ClickShootState.STANDING

	# Apply immediate upward impulse
	intent.desired_velocity = Vector3(
		player_character.velocity.x,
		player_character.velocity.y,
		player_character.velocity.z
	)
	intent.desired_rotation = player_character.mesh.rotation
	state_machine.set_movement_intent(intent)
	
func Physics_Update(_delta: float):
	# Handle horizontal movement while jumping
	var input_direction = state_machine.input.current_input.move
	var horizontal_input = Vector3(input_direction.x, 0.0, input_direction.y)
	var world_direction = player_character.mesh.global_transform.basis * horizontal_input
	
	intent.desired_velocity.x = world_direction.x * move_speed
	intent.desired_velocity.y = state_machine.locomotor.velocity.y
	intent.desired_velocity.z = world_direction.z * move_speed
	print(intent.desired_velocity)
	# Update animation blend position
	state_machine.anim_tree.set("parameters/Locomotion/Jumping/blend_position", intent.desired_velocity.y)

	state_machine.set_movement_intent(intent)
	
	if state_machine.locomotor.is_on_floor():
		state_machine.TransitionTo("Locomote")
		return
