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
## they hit play and request the server to spawn them
@rpc("any_peer")
func client_request_spawn() -> void:
	if multiplayer.is_server():
		server.spawn_player(multiplayer.get_remote_sender_id())

## Once the client has requested the spawn and the server has configured it, the server
## tells the client to spawn their player with the same configuration
@rpc("authority")
func client_spawn_player(position: Vector3, peer_id: int):
	client.spawn_player(peer_id, position)
	
## Each connected client will be streaming their authoritative state to the server.
## I realise we usually use server as authority but websockets are so laggy we're going the other way
@rpc("any_peer")
func client_send_state(state: Dictionary):
	if multiplayer.is_server():
		server.authoritative_handler.apply_authoritative_state(state, str(multiplayer.get_remote_sender_id()))

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
		
# the player shoots a weapon and needs to tell the server
@rpc("any_peer")
func player_shot_weapon(event: Dictionary) -> void:
	if multiplayer.is_server():
		server.player_shot_weapon(event, multiplayer.get_remote_sender_id())
		
# when the server is sending all player states to all players for replication
@rpc("authority")
func server_send_client_states(states: Dictionary) -> void:
	server.authoritative_handler.apply_authoritative_states(states)
