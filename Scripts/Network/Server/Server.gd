extends Node

## This node is our Server entrypoint. It will only exist on the server, not the
## client. The Network node will generally have RPC calls that delegate to this
## node as long as the instance is running in server mode. You'll likely see a
## lot of calls in Network look like this:
##
## 	@rpc("authority")
## 	func spawn_player() -> void:
##		if multiplayer.is_server():
##			server.spawn_player
##
## This way we can be very explicit about code that runs on the server
class_name Server

## the world root is where we load maps into
@export var world_root: Node

## The node that we loaded in as the current map and parented to the world root
var current_map: Node

## the map path we will tell the client to load when it asks
var current_map_path: String

## a lokup table of connected players
var players: Dictionary[int, DeterministicPlayerCharacter] = {}

# the remote player, playerpawn scene to load for remote players
var remote_player_scene = load("res://PlayerCharacter/PlayerPawn/PlayerPawn.tscn")

## the letterboxing and vignette layer we show in game
@export var in_game_ui: CanvasLayer

## track our own server tick - inc 1 each physics tick
var server_tick: int

## handler for receiving client-authority locations and updating them in sim
@export var authoritative_handler: AuthoritativeClientHandler

func _physics_process(_delta: float) -> void:
	server_tick += 1;
	
	# send all the connected clients the state as we know it
	send_client_states()

## On ready we need to inject ourselves into the network singleton
func _ready() -> void:
	Network.server = self
	
	## hide in game UI initially
	#in_game_ui.visible = false

## when a player connects we need to tell them to load the map we have loaded
func peer_connected(id: int) -> void:
	print("peer connected with ID: %s - telling them to load map %s" % [id, current_map_path])
	
	# use rpc_id to make sure we're only telling the client that just connected
	# so we don't cause all connected clients to reload the map
	Network.rpc_id(id, "client_load_map", current_map_path)

## A helper to load up a map on the server side. Clients are not connected yet
## so there's no need to worry about their loading logic here
func load_map(map_path: String) -> void:
	# check that map exists in our files
	if not ResourceLoader.exists(map_path):
		push_error("%s not found! Close the server down and set a valid --map" % map_path)
		return
	
	# otherwise we're all good!
	current_map_path = map_path
	
	# unload any map we have already loaded
	if current_map:
		current_map.queue_free()
	
	# load up the passed map
	current_map = load(map_path).instantiate()
	current_map.name = "Map"
	world_root.add_child(current_map)
	
	# hide the map start screen
	Network.client.toggle_map_start_screen(false)
	
	# set the maps server_camera to current
	current_map.server_camera.make_current()
	

## Spawn a player into the map. This is running on the server side and is the kick
## off for the clients to spawn their copy as well
func spawn_player(peer_id: int):
	# select a random spawn point
	var spawn_point: SpawnPoint = current_map.spawn_points.pick_random()
	
	# guard
	if not spawn_point:
		push_error("could not find a spawn point")
		return
	
	# blast out a player spawn to all clients
	Network.client_spawn_player.rpc(spawn_point.global_position, peer_id)
	
	# spawn a pawn on the server
	push_error("spawning PlayerPawn")
	# otherwise we want to spawn the pawn
	var new_node = remote_player_scene.instantiate()
	# set the name to the peer id for easy lookup
	new_node.name = str(peer_id)
	# attach them to the worldRoot node
	world_root.add_child(new_node)
	# position them after adding them
	new_node.global_position = spawn_point.global_position
	# register a remote player with the player registry
	PlayerRegistry.append_remote_player(new_node)
	
	## show in game UI
	in_game_ui.visible = true
	
## Despawn a player from the world
func despawn_player(peer_id: int):
	var player = PlayerRegistry.get_player(peer_id)
	# tear down the node
	player.queue_free()
	# remove from our list so we don't get null access
	PlayerRegistry.remove_player(peer_id)
	
## A helper to get a player from our lookup table
func get_player(peer_id):
	return PlayerRegistry.get_player(peer_id)

## When the player shoots their weapon we need to react and resimulate to check
## if we reckon they hit something
func player_shot_weapon(event: Dictionary, peer_id: int) ->void:
	var shoot_event = PlayerShotWeaponEvent.from_dict(event)

## Each tick the server sends all locations to all clients for simulation. Here
## we gather up all the state we need and dispatch them over the network
func send_client_states() -> void:
	if not multiplayer.is_server():
		return
		
	if server_tick % 3 != 0:
		return
	
	if multiplayer.multiplayer_peer == null:
		return

	if multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		return

	if multiplayer.get_peers().is_empty():
		return
		
	var states: Dictionary = {} # [peer_id: ClientAuthoritativeState]
	for player_id in PlayerRegistry.remote_players.keys():
		var player = PlayerRegistry.get_remote_player(str(player_id)) as PlayerPawn
		if not player:
			return
		
		states[player_id] = ClientAuthoritativeState.new(
			server_tick,
			player.global_position,
			player.mesh.global_rotation,
			player.current_state
		).to_dict()
		
	# send the collated data to all clients
	Network.server_send_client_states.rpc(states)
