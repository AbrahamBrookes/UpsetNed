extends State

# how much slide power we have left
@export var slide_force: float = 0.0
@export var slide_decay: float = 5.0

@export var mesh: Node3D

# when the player enters a slide from locomote, for a split second they can do a StandingBackflip
var can_backflip: bool
# and this is managed by a timer
@export var can_backflip_timer: Timer

func Enter(_extra_data = null):
	# toggle animation blend spaces for in-game pointy arms
	if state_machine.click_shoot:
		state_machine.click_shoot.current_clickshoot_state = ClickShoot.ClickShootState.SLIDING
		
	# set initial slide force based on current horizontal speed
	var horizontal_velocity = Vector3(player_character.velocity.x, 0.0, player_character.velocity.z)
	slide_force = horizontal_velocity.length() * 2.0  # arbitrary multiplier for slide power
	intent.desired_velocity = Vector3(
		player_character.velocity.x,
		0.0,
		player_character.velocity.z
	)
	
	# rotate the mesh to the velocity when we enter the slide
	if horizontal_velocity.length() > 0.1:
		intent.desired_rotation = mesh.global_transform.basis.get_euler()
		intent.desired_rotation.y = atan2(-player_character.velocity.x, -player_character.velocity.z)
	
	state_machine.set_movement_intent(intent)
	
	# start the can_backflip_timer
	can_backflip = true
	can_backflip_timer.start()
	

func Physics_Update(delta: float):
	
	if Input.is_action_just_pressed("jump"):
		jump()
		return
		
		
	# if slide force is less than the threshold, back to locomote
	if slide_force < 1.0:
		state_machine.TransitionTo("Prone")
		return

	# if the player isn't holding squat, back to locomote
	if not state_machine.input.current_input.squat:
		state_machine.TransitionTo("Locomote")
		return

	# Apply slide force
	intent.desired_velocity.x = slide_force * player_character.velocity.normalized().x
	intent.desired_velocity.z = slide_force * player_character.velocity.normalized().z
	
	state_machine.set_movement_intent(intent)

	# Decrease slide force over time
	slide_force -= slide_decay * delta  # arbitrary slide decay rate

func jump(_data = null) -> void:
	# if we can backflip, backflip
	if can_backflip:
		state_machine.TransitionTo("StandingBackflip")


func _on_timer_timeout() -> void:
	can_backflip = false
