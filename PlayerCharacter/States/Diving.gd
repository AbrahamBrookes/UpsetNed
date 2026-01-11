extends State

var jump_power_left = 0.0
@export var max_jump_power: float = 1.0
@export var jump_decay_rate: float = 5.0
@export var jump_velocity: float = 5.0
@export var move_speed: float = 0.1

@export var mesh: Node3D

@export var wall_flip_ray: RayCast3D

func Enter(_extra_data = null):
	# toggle animation blend spaces for in-game pointy arms
	if state_machine.click_shoot:
		state_machine.click_shoot.current_clickshoot_state = ClickShoot.ClickShootState.DIVING
		
	## Apply the current input to the dive when it starts
	var input_direction = state_machine.input.current_input.move
	#rotate input to camera
	var horizontal_input = Vector3(input_direction.x, 0.0, input_direction.y)
	var world_direction = horizontal_input.rotated(
		Vector3.UP,
		player_character.mouselook.camera_pivot.global_transform.basis.get_euler().y
	)

	# Apply immediate upward impulse
	intent.desired_velocity = Vector3(
		world_direction.x * 5,
		jump_velocity,
		world_direction.z * 5
	)
	
	jump_power_left = max_jump_power
	
	# the animations are using the slide animation, which are reversed so we 
	# want to rotate the mesh to the opposite of velocity when we enter the dive
	if player_character.velocity.length() > 0.1:
		intent.desired_rotation = mesh.global_transform.basis.get_euler()
		intent.desired_rotation.y = atan2(player_character.velocity.x, player_character.velocity.z)
	
	state_machine.set_movement_intent(intent)

func Physics_Update(delta: float):
	if wall_flip_ray.is_colliding():
		print('ray')
	
	# allow a tiny bit of input control if we have stalled
	if player_character.velocity.length() < 3.0:
		var input_direction = state_machine.input.current_input.move
		#rotate input to camera
		var horizontal_input = Vector3(input_direction.x, 0.0, input_direction.y)
		var world_direction = horizontal_input.rotated(
			Vector3.UP,
			player_character.mouselook.camera_pivot.global_transform.basis.get_euler().y + PI
		)
		
		
		intent.desired_velocity.x -= world_direction.x * move_speed
		intent.desired_velocity.z -= world_direction.z * move_speed
	
	
	# decay jump power
	if jump_power_left > 0.0:
		jump_power_left -= jump_decay_rate * delta
	else:
		jump_power_left = 0.0
		
	intent.desired_velocity.y += jump_power_left * delta
	
	state_machine.set_movement_intent(intent)
	
	if state_machine.locomotor.is_on_floor():
		state_machine.TransitionTo("DiveSlide")
		return

# in order to do a wallflip the player needs to press jump while the
# WallFlipRay is intersecting a wall
func jump(_data = null):
	if wall_flip_ray.is_colliding():
		# get the collision normal to determine flip direction
		var collision: Vector3 = wall_flip_ray.get_collision_normal()
		state_machine.TransitionTo("WallFlip", collision)
