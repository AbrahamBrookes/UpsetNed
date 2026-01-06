extends Node3D

## A SpawnPoint is a node that spawns players. This is just to have a type-safe
## node for spawning players
class_name SpawnPoint

## the mesh we can see in the editor so we know where the spawn points are
@export var mesh: MeshInstance3D

func _ready() -> void:
	# hide the mesh in game
	mesh.visible = false
