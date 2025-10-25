extends State

var jump_power_left = 0.0
@export var max_jump_power: float = 1.0
@export var jump_decay_rate: float = 5.0
@export var jump_velocity: float = 5.0
@export var move_speed: float = 5.0
	
func Physics_Update(delta: float):
	# Handle horizontal movement while jumping
	var input_direction = Vector2(
		Input.get_action_strength("run_l") - Input.get_action_strength("run_r"),
		Input.get_action_strength("run_f") - Input.get_action_strength("run_b")
	)
	var horizontal_input = Vector3(input_direction.x, 0.0, input_direction.y)
	var world_direction = player_character.global_transform.basis * horizontal_input
	
	player_character.velocity.x = world_direction.x * move_speed
	player_character.velocity.z = world_direction.z * move_speed

	# Apply gravity
	var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	player_character.velocity.y -= gravity * delta
	
	# Update animation blend position
	state_machine.anim_tree.set("parameters/Locomotion/Jumping/blend_position", player_character.velocity.y)
	
	player_character.move_and_slide()
	
	# Check if landed (only after moving)
	if player_character.is_on_floor() and player_character.velocity.y <= 0.0:
		state_machine.TransitionTo("Locomote")
