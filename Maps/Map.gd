extends Node3D

## The Map script is attached to the root node of our Map scenes and handles
## map-level stuff like choosing which spawn point to spawn a player into.
class_name Map

@export var spawn_points: Array[SpawnPoint]

## for now, on ready, spawn a player randmly
func _ready() -> void:
	spawn_player()

## spawn a player to a random spawn point
func spawn_player() -> void:
	# select a random spawn point
	var spawn_point: SpawnPoint = spawn_points.pick_random()
	
	# guard
	if not spawn_point: push_error("could not find a spawn point")
	
	# use the MultiplayerSpawner to spawn the defined player scene
	var player_path = spawn_point.spawner.get_spawnable_scene(0)
	var player = load(player_path).instantiate()

	spawn_point.add_child(player)
	
