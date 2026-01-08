extends State

var jump_power_left = 0.0
@export var max_jump_power: float = 1.0
@export var jump_decay_rate: float = 5.0
@export var jump_velocity: float = 5.0
@export var move_speed: float = 5.0

@export var mesh: Node3D

@export var wall_flip_ray: RayCast3D

func Enter(_extra_data = null):
	# toggle animation blend spaces for in-game pointy arms
	if state_machine.click_shoot:
		state_machine.click_shoot.current_clickshoot_state = ClickShoot.ClickShootState.STANDING

	# Apply immediate upward impulse
	intent.desired_velocity = Vector3(
		player_character.velocity.x,
		jump_velocity,
		player_character.velocity.z
	)
	intent.desired_rotation = player_character.mesh.rotation
	state_machine.set_movement_intent(intent)
	
	# reset jump power
	jump_power_left = max_jump_power
	
func Physics_Update(delta: float):
	# Handle horizontal movement while jumping
	var input_direction = state_machine.input.current_input.move
	var horizontal_input = Vector3(input_direction.x, 0.0, input_direction.y)
	var world_direction = mesh.global_transform.basis * horizontal_input
	
	intent.desired_velocity.x = world_direction.x * move_speed
	intent.desired_velocity.z = world_direction.z * move_speed
	intent.desired_rotation = player_character.mesh.rotation
	
	# Apply additional jump power while button held (optional)
	if jump_power_left > 0.0:
		jump_power_left -= jump_decay_rate * delta
		intent.desired_velocity.y += jump_power_left * delta
	else:
		jump_power_left = 0.0
	
	# Update animation blend position
	state_machine.anim_tree.set("parameters/Locomotion/Jumping/blend_position", intent.desired_velocity.y)
	
	state_machine.set_movement_intent(intent)
	
	if state_machine.locomotor.grounded:
		land()
		return

func land() -> void:
	# if the player is holding crouch when they land, go to sliding
	if state_machine.input.current_input.squat:
		slide()
		return
	
	state_machine.TransitionTo("Locomote")

# define the actions we can do from this state into other states

# in order to do a wallflip the player needs to press jump while the
# WallFlipRay is intersecting a wall
func jump(_data = null):
	if wall_flip_ray.is_colliding():
		# get the collision normal to determine flip direction
		var collision: Vector3 = wall_flip_ray.get_collision_normal()
		state_machine.TransitionTo("WallFlip", collision)

# if the player presses dive, dive
func dive(_data = null) -> void:
	state_machine.TransitionTo("Diving")

# if the player presses slide, slide
func slide(_data = null) -> void:
	state_machine.TransitionTo("Sliding")
