extends Control

## This is the screen that shows when you first join a map, where you can select
## a character model, loadout and spawn in
class_name MapStartScreen

func _on_spawn_button_pressed() -> void:
	# hide the map start screen
	Network.client.toggle_map_start_screen(false)
	
	# this should only be done on the server
	Network.server_spawn_player.rpc_id(1)
