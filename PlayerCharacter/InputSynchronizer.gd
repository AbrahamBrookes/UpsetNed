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

## tracking mouse delta as input
var last_mouse_delta: Vector2 = Vector2.ZERO

# we'll probably load this from preferences at some point
var mouse_sensitivity = 0.002

# make sure we start with a current_input in the tube
func _ready() -> void:
	current_input = InputPacket.new()

# get the mouse delta from the input event
func _input(event):
	if event is InputEventMouseMotion:
		last_mouse_delta = event.relative * mouse_sensitivity

## Handle streaming input where the player is holding a button
func _physics_process(_delta: float) -> void:
	# only run for the controlling instance
	if not is_multiplayer_authority():
		return
		
	# construct our input packet from client side inputs
	var move_dir = Vector2(
		Input.get_action_strength("run_l") - Input.get_action_strength("run_r"),
		Input.get_action_strength("run_f") - Input.get_action_strength("run_b")
	)
	var stunting = Input.is_action_pressed("dive")
	var squatting = Input.is_action_pressed("squat")
	var mouse_delta = last_mouse_delta
	
	# reset mouse delta or we get drift because the _input value is cached
	last_mouse_delta = Vector2.ZERO
	
	var packet: InputPacket = InputPacket.new(
		next_sequence,
		mouse_delta,
		move_dir,
		stunting,
		squatting
	)
	
	# send that packet to the server - serialize the packet before sending
	Network.send_input_packet.rpc_id(1, packet.to_dict())

	# apply the input locally right away - this same method is called on the server
	# once that rpc goes through
	apply_input_packet(packet)
	
	# increment the sequence every time we send a packet
	next_sequence += 1
	
	# append the packet to our pending inputs for reconciliation later
	pending_inputs.append(packet)

	# handle one-off presses for actions like shooting
	if Input.is_action_just_pressed("fire_r"):
		# on the server
		Network.dispatch_action.rpc_id(1, "fire_r")
		# locally
		state_machine.dispatch_action("fire_r")
		
	if Input.is_action_just_pressed("fire_l"):
		# on the server
		Network.dispatch_action.rpc_id(1, "fire_l")
		# locally
		state_machine.dispatch_action("fire_l")
	
	if Input.is_action_just_pressed("jump"):
		# on the server
		Network.dispatch_action.rpc_id(1, "jump")
		# locally
		state_machine.dispatch_action("jump")
	
	if Input.is_action_just_pressed("dive"):
		# on the server
		Network.dispatch_action.rpc_id(1, "dive")
		# locally
		state_machine.dispatch_action("dive")

	if Input.is_action_just_pressed("reload"):
		# on the server
		Network.dispatch_action.rpc_id(1, "reload")
		# locally
		state_machine.dispatch_action("reload")
	
	if Input.is_action_just_pressed("interact"):
		# on the server
		Network.dispatch_action.rpc_id(1, "interact")
		# locally
		state_machine.dispatch_action("interact")
	
	if Input.is_action_just_pressed("throw_grenade"):
		# on the server
		Network.dispatch_action.rpc_id(1, "throw_grenade")
		# locally
		state_machine.dispatch_action("throw_grenade")
	
	if Input.is_action_just_pressed("melee"):
		# on the server
		Network.dispatch_action.rpc_id(1, "melee")
		# locally
		state_machine.dispatch_action("melee")

## Apply an input packet and then run the state machine update - this is run
## locally first, then on the server, and again on reconciliation
func apply_input_packet(packet: InputPacket) -> void:
	current_input = packet

## When we receive the server's calculated state we need to reconcile the local
## state with that, then reapply inputs so we don't drift too far
func reconcile(state: AuthoritativeState) -> void:
	var player: DeterministicPlayerCharacter = PlayerRegistry.local_player

	# first, hard snap to authoritative state
	player.global_position = state.global_position
	player.velocity = state.velocity
	player.mesh.rotation = state.rotation
	player.mouselook.camera_pivot.rotation = state.camera_rotation
	player.grounded = state.grounded

	# then drop any inputs we have locally that server has already processed
	pending_inputs = pending_inputs.filter(
		func(p): return p.seq > state.last_sequence
	)

	# lastly, replay the remaining local inputs so we are only a couple packets
	# ahead of the server
	for packet in pending_inputs:
		apply_input_packet(packet)
