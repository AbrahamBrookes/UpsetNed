extends Node

## The ServerBootstrapper holds the logic around bootstrapping the instance into
## server mode. This includes reading the map param from the command line args
## and loading up the desired map. This is the entry point into the _server_ side
class_name ServerBootstrapper

## the world root is where we load maps into
@export var world_root: Node

## The node that we loaded in as the current map and parented to the world root
var current_map: Node

# bootstrap services
func boot() -> void:
	print("bootstrapping server app")
	
	# get the map from launch args
	var map = get_launch_arg("map")
	if map == "":
		push_error("You must pass a map ie --map=testmap when running the server. Close the server and add that arg and retry")
		return
	
	# concatenate the maps path to the passed arg so you can just pass the tscn
	# name and maybe a sub path if ya wanna
	map = "res://maps/%s.tscn" % map
	
	# attempt to load that map
	load_map(map)

## A helper to load up a map on the server side. Clients are not connected yet
## so there's no need to worry about their loading logic here
func load_map(map_path: String) -> void:
	# check that map exists in our files
	if not ResourceLoader.exists(map_path):
		push_error("%s not found! Close the server down and set a valid --map" % map_path)
		return
	
	# otherwise we're all good!
	
	# unload any map we have already loaded
	if current_map:
		current_map.queue_free()
	
	# load up the passed map
	current_map = load(map_path).instantiate()
	current_map.name = "Map"
	world_root.add_child(current_map)

## A helper to grab a launch arg by key
func get_launch_arg(key: String, default: String = "") -> String:
	for arg in OS.get_cmdline_args():
		if arg.begins_with("--%s=" % key):
			return arg.split("=", false, 1)[1]
	return default
