extends Node

## The Network node handles setting up multiplayer peers and connecting to servers.
## This is mainly a dumping ground for RPC calls

# We need references to the bootstrappers to get their state
@export var server_bootstrapper: ServerBootstrapper
@export var client_bootstrapper: ClientBootstrapper

## the world root is where we load maps into
var world_root: Node

## The node that we loaded in as the current map and parented to the world root
var current_map: Node

## the map path we will tell the client to load when it asks
var current_map_path: String

## When a player connects to the server the server tells them to load the map
## that is currently running on that server
@rpc("any_peer")
func client_load_map(map_path: String) -> void:
	# check that map exists in our files
	if not ResourceLoader.exists(map_path):
		push_error("%s not found in client files! Can not connect to the server runnign this map" % map_path)
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
	
