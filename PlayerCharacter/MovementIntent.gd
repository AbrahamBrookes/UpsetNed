extends RefCounted

## The MovementIntent is communicated from the state machine up to the locomotor
## (the thing that actually moves the player). This allows the state machine's
## current state to calculate movement but defer the actual move_and_slide to
## a central place
class_name MovementIntent

## the desired velocity the state wants to override on the locomotor
var desired_velocity: Vector3

## the desired rotation the state want to override on the locomotor
var desired_rotation: Vector3

## should we be applying gravity?
var apply_gravity: bool = true

func _init(
	_desired_velocity: Vector3 = Vector3.ZERO,
	_desired_rotation: Vector3 = Vector3.ZERO,
	_apply_gravity: bool = true
) -> void:
	desired_velocity = _desired_velocity
	desired_rotation = _desired_rotation
	apply_gravity = _apply_gravity
