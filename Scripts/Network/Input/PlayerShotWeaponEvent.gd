extends RefCounted

## The PlayerShotWeaponEvent is fired from the client to the server to tell the
## server that the player fired their weapon. The server will then compare the
## server_tick in the fire event with the locations in its cached location
## history in order to judge if the shot hit etc
## The player is effectively submitting a PhysicsRayQueryParameters3D to the server
class_name PlayerShotWeaponEvent

## The server tick when we pulled the trigger
var server_tick: int

## the global transform of the origin of the shot
var shot_origin: Vector3
var shot_destination: Vector3

func _init(
	_shot_origin: Vector3,
	_shot_destination: Vector3,
	_server_tick: int = Network.server.server_tick
):
	shot_origin = _shot_origin
	shot_destination = _shot_destination
	server_tick = _server_tick
	
## convert the packet to a dictionary for sending over the network
func to_dict() -> Dictionary:
	return {
		"shot_origin": shot_origin,
		"shot_destination": shot_destination,
		"server_tick": server_tick,
	}

## convert the packet back to this class once it has been received over the network
static func from_dict(d: Dictionary) -> PlayerShotWeaponEvent:
	return PlayerShotWeaponEvent.new(
		d.shot_origin,
		d.shot_destination,
		d.server_tick,
	)
