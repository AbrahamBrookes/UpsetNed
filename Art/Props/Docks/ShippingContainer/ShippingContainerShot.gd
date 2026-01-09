extends Node

## handles turning on some praticles when we get shot

@export var particles: Node3D

func _on_shot_receiver_shot_received(impact_position: Vector3, impact_normal: Vector3) -> void:
	# move particles to the impact position, align to impact normal and call .play
	particles.global_position = impact_position;
	print("impact_normal", impact_normal)
	# Orient so +Z faces away from surface
	particles.rotation = impact_normal
	
	# call play
	particles.play()
