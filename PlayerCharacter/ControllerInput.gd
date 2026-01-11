extends Node

## Think of this class as the literal controller the user is holding - be it a
## keyboard and mouse or a console controller. It listens to user input with
## relation to moving their PlayerPawn around their local simulation
class_name ControllerInput

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
