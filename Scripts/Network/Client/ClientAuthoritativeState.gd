extends RefCounted

## ClientAuthoritativeState is the position and rotation of a player at a specific tick.
## This is the client telling the server where they are, for the server to update them
## in its local simulation
class_name ClientAuthoritativeState

# the last known server tick, as a universal timer
var server_tick: int

# the global position of the player
var global_position: Vector3

# the rotation of the rotatable player mesh
var rotation: Vector3

# the velocity of the player
var velocity: Vector3

# the rotation of the camera
var camera_rotation: Vector3

# the current state of the state machine - an integer for serialization
# see StateMachine state_indexed_list
var current_state: int

func _init(
	_server_tick: int = Network.server.server_tick,
	_global_position: Vector3 = Vector3.ZERO,
	_rotation: Vector3 = Vector3.ZERO,
	_velocity: Vector3 = Vector3.ZERO,
	_camera_rotation: Vector3 = Vector3.ZERO,
	_current_state: int = 0,
) -> void:
	server_tick = _server_tick
	global_position = _global_position
	rotation = _rotation
	velocity = _velocity
	camera_rotation = _camera_rotation
	current_state = _current_state
	
## convert to a dictionary for sending over the network
func to_dict() -> Dictionary:
	return {
		"server_tick": server_tick,
		"global_position": global_position,
		"rotation": rotation,
		"velocity": velocity,
		"camera_rotation": camera_rotation,
		"current_state": current_state,
	}

## convert back to this class once it has been received over the network
static func from_dict(d: Dictionary) -> ClientAuthoritativeState:
	return ClientAuthoritativeState.new(
		d.server_tick,
		d.global_position,
		d.rotation,
		d.velocity,
		d.camera_rotation,
		d.current_state,
	)
