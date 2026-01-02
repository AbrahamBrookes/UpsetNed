extends MultiplayerSynchronizer

## The InputSynchronizer handles sending input from the client to the server.
class_name InputSynchronizer

## the player we are controlling
@export var player: DeterministicPlayerCharacter

@export var input_dir: Vector2 = Vector2.ZERO
@export var jumping: bool = false
@export var mouse_delta: Vector2 = Vector2.ZERO
var mouse_sensitivity = 0.002

func set_authority(authority_id: int) -> void:
	set_multiplayer_authority(authority_id)
	if authority_id != multiplayer.get_unique_id():
		set_physics_process(false)
		set_process(false)

func _input(event):
	if event is InputEventMouseMotion:
		mouse_delta = event.relative * mouse_sensitivity
		
func _physics_process(_delta: float) -> void:
	input_dir = Vector2(
		Input.get_action_strength("run_r") - Input.get_action_strength("run_l"),
		Input.get_action_strength("run_b") - Input.get_action_strength("run_f")
	)

func _process(_delta: float) -> void:
	# when we press jump we need to call the single jump event
	if Input.is_action_just_pressed("jump"):
		jump.rpc()
	# but we also want to track if we are holding jump for the sake of boost
	jumping = Input.is_action_pressed("jump")

@rpc
func jump() -> void:
	if multiplayer.is_server():
		# if the current player state can jump, jump
		if player.stateMachine.current_state.has_method("jump"):
			player.stateMachine.current_state.jump()
