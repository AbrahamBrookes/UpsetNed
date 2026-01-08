extends Node

## If the player enters my area, kill them
class_name KillBox


func _on_area_3d_body_entered(body: Node3D) -> void:
	var player = body as DeterministicPlayerCharacter;
	if not player:
		return
	
	player.kill()
	
