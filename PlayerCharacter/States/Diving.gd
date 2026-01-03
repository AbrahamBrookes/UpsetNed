extends State

var jump_power_left = 0.0
@export var max_jump_power: float = 1.0
@export var jump_decay_rate: float = 5.0
@export var jump_velocity: float = 5.0
@export var move_speed: float = 5.0

@export var mesh: Node3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	animation_override = "Diving"

func Enter(_extra_data = null):
	# toggle animation blend spaces for in-game pointy arms
	if state_machine.click_shoot:
		state_machine.click_shoot.sliding = true
	# Apply immediate upward impulse
	player_character.velocity.y = jump_velocity
	jump_power_left = max_jump_power
	
	# the animations are using the slide animation, which are reversed so we 
	# want to rotate the mesh to the opposite of velocity when we enter the dive
	if player_character.velocity.length() > 0.1:
		var mesh_rotation = mesh.global_transform.basis.get_euler()
		mesh_rotation.y = atan2(player_character.velocity.x, player_character.velocity.z)
		mesh.rotation = mesh_rotation
	

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
		state_machine.TransitionTo("DiveSlide")
