extends State

## When a player jumos off a wall they do a badass flip. When they move the mouse we are using a
## blend space to blend them between a back flip or side flip (cartwheel).

var jump_power_left = 0.0
@export var max_jump_power: float = 1.0
@export var jump_decay_rate: float = 5.0
@export var jump_velocity: float = 5.5
@export var move_speed: float = 5.0

@export var mesh: Node3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

## must pass in the ray cast collision so we can get the wall normal
func Enter(extra_data: Vector3 = Vector3.BACK):
	# toggle animation blend spaces for in-game pointy arms TODO: animations for shooting during wall flip
	# if state_machine.click_shoot:
	# 	state_machine.click_shoot.sliding = true

	# apply wall flip impulse
	player_character.velocity += extra_data * jump_velocity

	# Apply immediate upward impulse
	player_character.velocity.y = jump_velocity
	jump_power_left = max_jump_power
	
	# the animations are using the slide animation, which are reversed so we 
	# want to rotate the mesh to the opposite of velocity when we enter the dive
	# if player_character.velocity.length() > 0.1:
	# 	var mesh_rotation = mesh.global_transform.basis.get_euler()
	# 	mesh_rotation.y = atan2(-player_character.velocity.x, -player_character.velocity.z)
	# 	mesh.rotation = mesh_rotation
	

func Physics_Update(delta: float):
	# Apply additional jump power while button held (optional)
	if jump_power_left > 0.0:
		jump_power_left -= jump_decay_rate * delta
		player_character.velocity.y += jump_power_left * delta
	else:
		jump_power_left = 0.0

	# Apply gravity
	player_character.velocity.y -= gravity * delta
	
	player_character.move_and_slide()
	
	# Check if landed (only after moving)
	if player_character.is_on_floor() and player_character.velocity.y <= 0.0:
		# if the player is holding crouch when they land, go to sliding
		if Input.is_action_pressed("squat"):
			state_machine.TransitionTo("Sliding")
			return
			
		state_machine.TransitionTo("Locomote")
