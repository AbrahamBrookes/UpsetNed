extends Node

## The Network node handles setting up multiplayer peers and connecting to servers.
## This is mainly a dumping ground for RPC calls and acts as a central controller
## between the client and the server - Autoloaded as "Network"

## since Network is a global singleton, dependencies must inject themselves
var client: Client
var server: Server

## When a player connects to the server the server tells them to load the map
## that is currently running on that server
@rpc("any_peer")
func client_load_map(map_path: String) -> void:
	if not multiplayer.is_server():
		client.load_map(map_path)

## Before a game, players get a MapStartScreen. Once they set their loadout etc
## the hit play, and we spawn them into the world on the server using the maps
## MultiplayerSpawner node so that they are synced to all clients
@rpc("any_peer")
func server_spawn_player() -> void:
	if multiplayer.is_server():
		server.spawn_player(multiplayer.get_remote_sender_id())

## players need to despawn without breaking their game
@rpc("any_peer")
func server_despawn_player() -> void:
	# remove the player on the server and the MultiplayerSpawner will propagate
	# the node removal to clients
	if multiplayer.is_server():
		server.despawn_player(multiplayer.get_remote_sender_id())

## hide/show the map start screen on the client
@rpc("authority")
func client_toggle_map_start_screen(state: bool = true):
	if not multiplayer.is_server():
		client.toggle_map_start_screen(state)

## We send inputs to the server for simulation there
@rpc("any_peer", "unreliable")
func send_input_packet(packet: Dictionary) -> void:
	if multiplayer.is_server():
		server.input_handler.cache_input(multiplayer.get_remote_sender_id(), InputPacket.from_dict(packet))

## When we have processed input, we send the real state back to the client
@rpc("authority")
func send_authoritative_state(state: Dictionary):
	pass
	if not multiplayer.is_server():
		PlayerRegistry.local_player.input_synchronizer.reconcile(AuthoritativeState.from_dict(state))
		
# we react to one-time input presses by dispatching the relevant action to the server
@rpc("any_peer")
func dispatch_action(action: String) -> void:
	if multiplayer.is_server():
		server.dispatch_action(multiplayer.get_remote_sender_id(), action)
		
# the player shoots a weapon and needs to tell the server
@rpc("any_peer")
func player_shot_weapon(event: Dictionary) -> void:
	if multiplayer.is_server():
		server.player_shot_weapon(event, multiplayer.get_remote_sender_id())
		
