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
	#Network.send_input_packet.rpc_id(1, packet.to_dict())

	# apply the input locally right away - this same method is called on the server
	# once that rpc goes through
	apply_input_packet(packet)
	
	# increment the sequence every time we send a packet
	next_sequence += 1

## Apply an input packet and then run the state machine update - this is run
## locally first, then on the server, and again on reconciliation
func apply_input_packet(packet: InputPacket) -> void:
	current_input = packet
