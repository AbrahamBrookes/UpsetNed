extends Node

## The ServerBootstrapper holds the logic around bootstrapping the instance into
## server mode. This includes reading the map param from the command line args
## and loading up the desired map. This is the entry point into the _server_ side
class_name ServerBootstrapper

## The Server handles all the logic once the server is up and running
@export var server: Server

# bootstrap services
func boot() -> void:
	print("bootstrapping server app")
	
	# create the actual server
	var server_peer = ENetMultiplayerPeer.new()
	# make it a server on our chose port
	server_peer.create_server(8080)
	# pass it to the built in multiplayer API so this instance of the game
	# will know it is a server, not a client
	multiplayer.multiplayer_peer = server_peer
	
	# start listening to client connection events
	multiplayer.peer_connected.connect(peer_connected)
	#multiplayer.peer_disconnected.connect(rem_player)
	
	# get the map from launch args
	var map = Util.get_launch_arg("map")
	if map == "":
		push_error("You must pass a map ie --map=testmap when running the server. Close the server and add that arg and retry")
		return

	# concatenate the maps path to the passed arg so you can just pass the tscn
	# name and maybe a sub path if ya wanna
	map = "res://maps/%s.tscn" % map
	
	# attempt to load that map
	server.load_map(map)
	
## When a peer connects send them the map to load
func peer_connected(id: int) -> void:
	server.peer_connected(id)
