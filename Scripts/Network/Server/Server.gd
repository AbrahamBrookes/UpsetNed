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

## a reference to the player spawner in the main screen, for spawning players
@export var player_spawner: PlayerSpawner

## a reference to the server input handler child node
@export var input_handler: ServerInputHandler

## the letterboxing and vignette layer we show in game
@export var in_game_ui: CanvasLayer

## track our own server tick - inc 1 each physics tick
var server_tick: int

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
	

## Spawn a player into the map. This is using the PlayerSpawner's custom spawn
## function in order to set up the player when they are spawned into the client
func spawn_player(peer_id: int):
	# select a random spawn point
	var spawn_point: SpawnPoint = current_map.spawn_points.pick_random()
	
	# guard
	if not spawn_point:
		push_error("could not find a spawn point")
		return
	
	# use the PlayerSpawner to spawn our player scene
	var player = player_spawner.spawn({
		"peer_id": peer_id,
		"transform": spawn_point.global_transform
	})

	# add to our lookup table
	players[peer_id] = player
	
	## show in game UI
	in_game_ui.visible = true
	
## Despawn a player from the world
func despawn_player(peer_id: int):
	var player = players[peer_id]
	# tear down the node
	player.queue_free()
	# remove from our list so we don't get null access
	players.erase(peer_id)

### when we receive an input packet from a client we need to apply that packet to
### the player character we are simulating on the server
#func apply_input(peer_id: int, dict: Dictionary) -> void:
	## find the player for that peer id
	#var player: DeterministicPlayerCharacter = get_player(peer_id)
	#if not player: return
	#
	## deserialize our input packet
	#var packet = InputPacket.from_dict(dict)
	#
	## get the server physics delta which is hard-set in preferences
	#var hz = Engine.physics_ticks_per_second
	#var physics_delta: float = 1.0 / hz
	#
	## apply the input packet to that player
	#player.input_synchronizer.apply_input_packet(packet, physics_delta)

## when the player presses jump, jump
func dispatch_action(peer_id: int, action: String) -> void:
	# find the player for that peer id
	var player: DeterministicPlayerCharacter = get_player(peer_id)
	if not player: return
	
	player.state_machine.dispatch_action(action)
	
## A helper to get a player from our lookup table
func get_player(peer_id) -> DeterministicPlayerCharacter:
	# find the player for that peer id
	var player: DeterministicPlayerCharacter = players.get(peer_id, null)
	
	# guard
	if not player:
		push_error("could not find player for peer ID: %s" % peer_id)
		return null
	
	return player

## When the player shoots their weapon we need to react and resimulate to check
## if we reckon they hit something
func player_shot_weapon(event: Dictionary, peer_id: int) ->void:
	var shoot_event = PlayerShotWeaponEvent.from_dict(event)
	# delegate out to the input handler, where the rest of this logic is
	#input_handler.player_shot_weapon(shoot_event, peer_id)

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
	for player_id in players.keys():
		var player = players[player_id]
		states[player_id] = ClientAuthoritativeState.new(
			server_tick,
			player.global_position,
			player.mesh.global_rotation,
			player.velocity,
			player.mouselook.camera_pivot.global_rotation,
			player.state_machine.current_state.state_index
		).to_dict()
	Network.server_send_client_states.rpc(states)
