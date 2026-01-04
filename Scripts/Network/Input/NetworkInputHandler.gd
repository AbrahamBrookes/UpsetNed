extends Node

## This node is a component on the Network global that groups our server-side
## input logic, so we don't pollute the Network script
class_name NetworkInputHandler

@rpc("authority")
func send_player_fire_r() -> void:
	# placeholder for now
	pass
	
@rpc("authority")
func send_player_fire_l() -> void:
	# placeholder for now
	pass

@rpc("any_peer")
func send_player_jump() -> void:
	if multiplayer.is_server():
		Network.server.player_jump(multiplayer.get_remote_sender_id())

@rpc("authority")
func send_player_dive() -> void:
	# placeholder for now
	pass

@rpc("authority")
func send_player_reload() -> void:
	# placeholder for now
	pass

@rpc("authority")
func send_player_interact() -> void:
	# placeholder for now
	pass

@rpc("authority")
func send_player_throw_grenade() -> void:
	# placeholder for now
	pass

@rpc("authority")
func send_player_melee() -> void:
	# placeholder for now
	pass
