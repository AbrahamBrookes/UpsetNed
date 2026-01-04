extends Node

## Since we are in a multiplayer game we need to siphon the controls through to
## the server and read back the input for drift compensation. We will keep all
## the movement code the same as it is on the client now, but the server will
## send back the _correct_ positions and the client will rectify any drift.
## This script is a central place to handle input from the player, which can be
## read by the clients statemachine as well as being sent to the server, where
## the server will also apply it to the state machine it is simulating.
## One off actions like shooting or jumping will be RPC'd to the server since
## that gives us a more reliable way to ensure the message gets through and they
## are one off actions that require reliability over latency, for which we'll 
## use our autoloaded network node. Steaming inputs like directional input will
## be unreliably RPC'd to the server using our InputPacket struct
class_name InputSynchronizer

## Hold a local sequence of input packets, for reconciliation
var next_sequence: int = 0

## A list of inputs that the server hasn't agreed to yet
var pending_inputs: Array[InputPacket]

## the current input that the state machine will read from when it ticks
var current_input: InputPacket

## a reference to the state machine so we can tick it
@export var state_machine: StateMachine

## Handle streaming input where the player is holding a button
func _physics_process(delta: float) -> void:
	# never run input on the server
	if multiplayer.is_server():
		return
	
	# only run for the controlling instance
	if not is_multiplayer_authority():
		return
		
	# construct our input packet from client side inputs
	var move_dir = Vector2(
		Input.get_action_strength("run_r") - Input.get_action_strength("run_l"),
		Input.get_action_strength("run_b") - Input.get_action_strength("run_f")
	)
	var jumping = Input.is_action_pressed("jump")
	var stunting = Input.is_action_pressed("dive")
	
	var packet: InputPacket = InputPacket.new(
		next_sequence,
		move_dir,
		jumping,
		stunting
	)
	
	# send that packet to the server - serialize the packet before sending
	Network.send_input_packet.rpc_id(1, packet.to_dict())
	
	# increment the sequence every time we send a packet
	next_sequence += 1
	
	# append the packet to our pending inputs for reconciliation later
	pending_inputs.append(packet)

	# apply the input locally right away
	apply_input_packet(packet, delta)

	# handle one-off presses for actions like shooting
	if Input.is_action_just_pressed("fire_r"):
		Network.input_handler.send_player_fire_r.rpc_id(1)
		
	if Input.is_action_just_pressed("fire_l"):
		Network.input_handler.send_player_fire_l.rpc_id(1)
	
	if Input.is_action_just_pressed("jump"):
		Network.input_handler.send_player_jump.rpc_id(1)
	
	if Input.is_action_just_pressed("dive"):
		Network.input_handler.send_player_dive.rpc_id(1)

	if Input.is_action_just_pressed("reload"):
		Network.input_handler.send_player_reload.rpc_id(1)
	
	if Input.is_action_just_pressed("interact"):
		Network.input_handler.send_player_interact.rpc_id(1)
	
	if Input.is_action_just_pressed("throw_grenade"):
		Network.input_handler.send_player_throw_grenade.rpc_id(1)
	
	if Input.is_action_just_pressed("melee"):
		Network.input_handler.send_player_melee.rpc_id(1)

## Apply an input packet and then run the state machine update
func apply_input_packet(packet: InputPacket, delta: float) -> void:
	current_input = packet
	print("applying packet")
	state_machine.current_state.Physics_Update(delta)
	
	
