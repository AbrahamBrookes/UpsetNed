extends RefCounted

## AuthoritativeState is the position and rotation of a player at a specific tick.
## This gets sent back to the client and the client nudgets itself back in to
## synchrony with this state, to correct drift
class_name AuthoritativeState

# the sequence of the last input packet we processed to get to this state
var last_sequence: int

# the global position of the player
var global_position: Vector3

# the rotation of the rotatable player mesh
var rotation: Vector3

# the velocity of the player
var velocity: Vector3

# the rotation of the camera
var camera_rotation: Vector3

# let the server decide if we are on the floor or not
var grounded: bool

func _init(
	_last_sequence: int = 0,
	_global_position: Vector3 = Vector3.ZERO,
	_rotation: Vector3 = Vector3.ZERO,
	_velocity: Vector3 = Vector3.ZERO,
	_camera_rotation: Vector3 = Vector3.ZERO,
	_grounded: bool = true
) -> void:
	last_sequence = _last_sequence
	global_position = _global_position
	rotation = _rotation
	velocity = _velocity
	camera_rotation = _camera_rotation
	grounded= _grounded
	
## convert to a dictionary for sending over the network
func to_dict() -> Dictionary:
	return {
		"last_sequence": last_sequence,
		"global_position": global_position,
		"rotation": rotation,
		"velocity": velocity,
		"camera_rotation": camera_rotation,
		"grounded": grounded
	}

## convert back to this class once it has been received over the network
static func from_dict(d: Dictionary) -> AuthoritativeState:
	return AuthoritativeState.new(
		d.last_sequence,
		d.global_position,
		d.rotation,
		d.velocity,
		d.camera_rotation,
		d.grounded
	)
