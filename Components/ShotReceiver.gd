extends Node3D

## When something gets show it needs a way to react like spawn particles
class_name ShotReceiver

## we pretty much just emit the signal so context can listen to it
signal shot_received(impact_position: Vector3, impact_normal: Vector3)

func receive_shot(impact_position: Vector3, impact_normal: Vector3) -> void:
	print("received")
	emit_signal("shot_received", impact_position, impact_normal)
