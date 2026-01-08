extends State

# how much slide power we have left
@export var slide_force: float = 0.0
@export var slide_decay: float = 5.0

# how much boost we give the player on the slide
@export var slide_boost: float = 1.5

@export var mesh: Node3D

func _ready():
	animation_override = "Diving"

func Enter(_extra_data = null):
	# toggle animation blend spaces for in-game pointy arms
	if state_machine.click_shoot:
		state_machine.click_shoot.current_clickshoot_state = ClickShoot.ClickShootState.DIVING
	
	# set initial slide force based on current horizontal speed
	var horizontal_velocity = Vector3(player_character.velocity.x, 0.0, player_character.velocity.z)
	slide_force = horizontal_velocity.length() * slide_boost  # multiplier for slide power
	# rotate the mesh to the velocity when we enter the slide
	if horizontal_velocity.length() > 0.1:
		var mesh_rotation = mesh.global_transform.basis.get_euler()
		mesh_rotation.y = atan2(horizontal_velocity.x, horizontal_velocity.z)
		intent.desired_rotation = mesh_rotation

func Physics_Update(delta: float):
	# if slide force is less than the threshold, back to locomote
	if slide_force < 0.01:
		state_machine.TransitionTo("Prone")
		return

	# if the player isn't holding squat, back to locomote
	if not state_machine.input.current_input.stunt:
		state_machine.TransitionTo("Locomote")
		return

	# Apply slide force
	intent.desired_velocity.x = slide_force * player_character.velocity.normalized().x
	intent.desired_velocity.z = slide_force * player_character.velocity.normalized().z

	state_machine.set_movement_intent(intent)
	
	# Decrease slide force over time
	slide_force -= slide_decay * delta  # arbitrary slide decay rate
