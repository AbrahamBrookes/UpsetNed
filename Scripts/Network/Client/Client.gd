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

## hide/show the start map screen
func toggle_map_start_screen(state: bool = true):
	if current_map:
		current_map.map_start_screen.visible = state
