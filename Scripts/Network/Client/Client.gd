extends Node

## The Client node only does anything on the client, not the server. Have a look
## at the Server.gd script as well to get the context. Generally our Network.gd
## will make RPC calls from the server to this client node. You'll probably see
## RPC calls in the Network.gd script that look like this:
##
## 	@rpc("any_peer")
## 	func load_map(map_path: String) -> void:
##		if not multiplayer.is_server():
##			client.load_map(map_path)
##
## This allows us to use the Network node as a controller that routes logic out
## when it should only run on the client
class_name Client

## the world root is where we load maps into
@export var world_root: Node

## The node that we loaded in as the current map and parented to the world root
var current_map: Node

## the map path we will tell the client to load when it asks
var current_map_path: String

## a reference to the in-game UI
@export var in_game_ui: InGameUI

## a reference to the authoritative client synchronizer
@export var authoritative_synchronizer: AuthoritativeClientSynchronizer

## the client is given the server_tick from the server
var server_tick: int

# the local player controller player character scene to spawn
var local_player_scene = load("res://PlayerCharacter/PlayerCharacter.tscn")

# the remote player, playerpawn scene to load for remote players
var remote_player_scene = load("res://PlayerCharacter/PlayerPawn/PlayerPawn.tscn")

## On ready we need to inject ourselves into the network singleton
func _ready() -> void:
	Network.client = self

## load the given map
func load_map(map_path: String) -> void:
	# check that map exists in our files
	if not ResourceLoader.exists(map_path):
		push_error("%s not found in client files! Can not connect to the server running this map" % map_path)
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
	
	# show the map start screen
	toggle_map_start_screen(true)

## hide/show the start map screen
func toggle_map_start_screen(state: bool = true):
	if current_map:
		in_game_ui.map_start_screen.visible = state
		
		# if showing
		if state:
			# allow mouse input
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		# else hiding
		else:
			# set the server camera current
			current_map.server_camera.make_current()
			# capture mouse input
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			
## When the server tells us to spawn a player it might be us or it might be a
## different player, so we need to know which scene to spawn - our player controller
## or the player pawn
func spawn_player(peer_id: int, position: Vector3):
	# if we are spawning ourselves, use the DeterministicPlayerCharacter
	if peer_id == multiplayer.get_unique_id():
		push_error("spawning DeterministicPlayerCharacter")
		var new_node = local_player_scene.instantiate() as DeterministicPlayerCharacter
		# set the name to the peer id for easy lookup
		new_node.name = str(peer_id)
		new_node.set_multiplayer_authority(peer_id)
		# attach them to the worldRoot node
		world_root.add_child(new_node)
		# position them after adding them
		new_node.global_position = position
		# register it with the player registry
		PlayerRegistry.set_local_player(new_node)
	else:
		push_error("spawning PlayerPawn")
		# otherwise we want to spawn the pawn
		var new_node = remote_player_scene.instantiate()
		# set the name to the peer id for easy lookup
		new_node.name = str(peer_id)
		# attach them to the worldRoot node
		world_root.add_child(new_node)
		# position them after adding them
		new_node.global_position = position
		# register a remote player with the player registry
		PlayerRegistry.append_remote_player(new_node)
		
