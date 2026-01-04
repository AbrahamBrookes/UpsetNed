extends RefCounted

## The InputPacket is a struct for sending input to the server, and applying
## input to a player
class_name InputPacket

## the client-bound sequence number, so we can count from when a player first
## starts sending input, and compare it on the server as we receive packets
var seq: int

## the mouse delta for moving the camera
var mouse_delta: Vector2

## the movement input being held
var move: Vector2

## is the jump action being held
var jump: bool

## is the stunt action being held
var stunt: bool

## is the squat action being held
var squat: bool

func _init(
	_seq: int = 0,
	_mouse_delta: Vector2 = Vector2.ZERO,
	_move: Vector2 = Vector2.ZERO,
	_jump: bool = false,
	_stunt: bool = false,
	_squat: bool = false
):
	seq = _seq
	mouse_delta = _mouse_delta
	move = _move
	jump = _jump
	stunt = _stunt
	squat = _squat
	
## convert the packet to a dictionary for sending over the network
func to_dict() -> Dictionary:
	return {
		"seq": seq,
		"mouse_delta": mouse_delta,
		"move": move,
		"jump": jump,
		"stunt": stunt,
		"squat": squat
	}

## convert the packet back to this class once it has been received over the network
static func from_dict(d: Dictionary) -> InputPacket:
	return InputPacket.new(
		d.seq,
		d.mouse_delta,
		d.move,
		d.jump,
		d.stunt,
		d.squat
	)
