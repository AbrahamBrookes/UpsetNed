extends Node

## Since we are in a multiplayer game we need to siphon the controls through to
## the server and read back the input for drift compensation. We will keep all
## the movement code the same as it is on the client now, but the server will
## send back the _correct_ positions and the client will rectify any drift. So
## This script is a central place to handle input from the player, which can be
## read by the clients statemachine as well as being sent to the server, where
## the server will also apply it to the state machine it is simulating.
class_name InputHandler

## input will be synced to the server using a MultiplayerSynchronizer node
@export var input: Dictionary[String, Variant] = {
	"move_dir": Vector2.ZERO,
	"jumping": false,
	"stunting": false
}

## one off actions like shooting or jumping will be RPC'd to the server since
## that gives us a more reliable way to ensure the message gets through and they
## are one off actions that require reliability over latency, for which we'll 
## use our autoloaded network node

## Handle streaming input where the player is holding a button
func _physics_process(_delta: float) -> void:
	# these are synced to the server using a MultiplayerSynchronizer node
	input.move_dir = Vector2(
		Input.get_action_strength("run_l") - Input.get_action_strength("run_r"),
		Input.get_action_strength("run_f") - Input.get_action_strength("run_b")
	)
	input.jumping = Input.is_action_pressed("jump")
	input.stunting = Input.is_action_pressed("dive")

	# handle one-off presses for actions like shooting
	if Input.is_action_just_pressed("shoot"):
		Network.send_player_shoot()
	
	if Input.is_action_just_pressed("jump"):
		Network.send_player_jump()
	
	if Input.is_action_just_pressed("dive"):
		Network.send_player_dive()

	if Input.is_action_just_pressed("reload"):
		Network.send_player_reload()
	
	if Input.is_action_just_pressed("interact"):
		Network.send_player_interact()
	
	if Input.is_action_just_pressed("throw_grenade"):
		Network.send_player_throw_grenade()
	
	if Input.is_action_just_pressed("melee"):
		Network.send_player_melee()
