extends RefCounted

## AuthoritativeState is the position and rotation of a player at a specific tick.
## This gets sent back to the client and the client nudgets itself back in to
## synchrony with this state, to correct drift
class_name AuthoritativeState

# the sequence of the last input packet we processed to get to this state
var last_sequence: int

# the global position of the player
var global_position: Vector3

# the velocity of the player
var velocity: Vector3

# the rotation of the rotatable part of the player
var rotation: Vector3

func _init(
	_last_sequence: int = 0,
	_global_position: Vector3 = Vector3.ZERO,
	_rotation: Vector3 = Vector3.ZERO,
	_velocity: Vector3 = Vector3.ZERO
) -> void:
	last_sequence = _last_sequence
	global_position = _global_position
	rotation = _rotation
	velocity = _velocity
	
## convert to a dictionary for sending over the network
func to_dict() -> Dictionary:
	return {
		"last_sequence": last_sequence,
		"global_position": global_position,
		"rotation": rotation,
		"velocity": velocity,
	}

## convert back to this class once it has been received over the network
static func from_dict(d: Dictionary) -> AuthoritativeState:
	return AuthoritativeState.new(
		d.last_sequence,
		d.global_position,
		d.rotation,
		d.velocity,
	)
