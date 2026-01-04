extends State

var jump_power_left = 0.0
@export var max_jump_power: float = 1.0
@export var jump_decay_rate: float = 5.0
@export var jump_velocity: float = 5.0
@export var move_speed: float = 5.0

@export var mesh: Node3D

@export var wall_flip_ray: Node3D

func Enter(_extra_data = null):
	# toggle animation blend spaces for in-game pointy arms
	if state_machine.click_shoot:
		state_machine.click_shoot.sliding = false
	# Apply immediate upward impulse
	player_character.velocity.y = jump_velocity
	jump_power_left = max_jump_power
	
func Physics_Update(delta: float):
	
	# in order to do a wallflip the player needs to press jump while the
	# WallFlipRay is intersecting a wall
	if Input.is_action_just_pressed("jump"):
		print(wall_flip_ray.is_colliding())
		if wall_flip_ray.is_colliding():
			# get the collision normal to determine flip direction
			var collision: Vector3 = wall_flip_ray.get_collision_normal()
			state_machine.TransitionTo("WallFlip", collision)
			return
		
	# if the player presses dive, dive
	if Input.is_action_just_pressed("dive"):
		state_machine.TransitionTo("Diving")
		return
		
	# Handle horizontal movement while jumping
	var input_direction = state_machine.input.current_input.move
	var horizontal_input = Vector3(input_direction.x, 0.0, input_direction.y)
	var world_direction = mesh.global_transform.basis * horizontal_input
	
	player_character.velocity.x = world_direction.x * move_speed
	player_character.velocity.z = world_direction.z * move_speed
	
	# Apply additional jump power while button held (optional)
	if Input.is_action_pressed("jump") and jump_power_left > 0.0:
		jump_power_left -= jump_decay_rate * delta
		player_character.velocity.y += jump_power_left * delta
	else:
		jump_power_left = 0.0

	# Apply gravity
	var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	player_character.velocity.y -= gravity * delta
	
	# Update animation blend position
	state_machine.anim_tree.set("parameters/Locomotion/Jumping/blend_position", player_character.velocity.y)
	
	player_character.move_and_slide()
	
	# Check if landed (only after moving)
	if player_character.is_on_floor() and player_character.velocity.y <= 0.0:
		# if the player is holding crouch when they land, go to sliding
		if Input.is_action_pressed("squat"):
			state_machine.TransitionTo("Sliding")
			return
			
		state_machine.TransitionTo("Locomote")
