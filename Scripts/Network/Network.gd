extends Node

## The Network node handles setting up multiplayer peers and connecting to servers.
## This is mainly a dumping ground for RPC calls and acts as a central controller
## between the client and the server

## proxy to our child nodes that group specific logic
@export var input_handler: NetworkInputHandler

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

## We send inputs to the server for simulation there
@rpc("any_peer", "unreliable_ordered")
func send_input_packet(packet: Dictionary) -> void:
	if multiplayer.is_server():
		server.apply_input(multiplayer.get_remote_sender_id(), packet)
