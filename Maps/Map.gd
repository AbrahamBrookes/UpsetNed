extends Node3D

## The Map script is attached to the root node of our Map scenes and handles
## map-level stuff like choosing which spawn point to spawn a player into.
class_name Map

## the list of spawn points in the map, for spawning players
@export var spawn_points: Array[SpawnPoint]

## the map start screen
@export var map_start_screen: MapStartScreen

func _ready() -> void:
	# if we are on the server, hide the main menu screen so we can spectate
	if Util.running_as_server():
		map_start_screen.visible = false
	
func _on_map_start_screen_spawn() -> void:
	# hide the map start screen
	map_start_screen.visible = false
	
	# this should only be done on the server
	Network.server_spawn_player.rpc_id(1)
