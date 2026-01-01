extends Node

const SERVER_PORT = 8080
const SERVER_IP ="127.0.0.1"

# the player scene that we instantiate as a client - only one of these per client
# as remote players are effectively just static bodies we simulate, not control
var multiplayer_scene = preload("res://PlayerCharacter/MultiplayerCharacter.tscn")

# for now we'll forgo any map selection, and hardcode the map used
var map_to_load: String = "res://Maps/Test/TestMap.tscn" 

# when we call host, we are configuring this instance of the godot game to be a
# server. The same binary can be server or client, and we conditionally check if
# we are a server or a client to run different logic.
func host():
	# load up our map (later this will have more logic ie map selection.
	# this seems cool, like we could watch the game from the server
	get_tree().change_scene_to_file(map_to_load)

	# create a multiplayer peer
	var server_peer = ENetMultiplayerPeer.new()
	# make it a server on our chose port
	server_peer.create_server(SERVER_PORT)
	# pass it to the built in multiplayer API so this instance of the game
	# will know it is a server, not a client
	multiplayer.multiplayer_peer = server_peer
	
	# start listening to client connection events
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(rem_player)

# when we join a game we are establishing that we are a client, not a server. So
# this code is only ever run on a client machine, not the server. Eventually this
# will be behind some kind of server browser or matchmaking system
func join():
	# load up our map so the player can run around in it on the client side
	get_tree().change_scene_to_file(map_to_load)

	# create a multiplayer peer
	var server_peer = ENetMultiplayerPeer.new()
	# make it a client connecting to the server ip and port
	server_peer.create_client(SERVER_IP, SERVER_PORT)
	# pass it to the built in multiplayer API so this instance of the game
	# will know it is a client, not a server
	multiplayer.multiplayer_peer = server_peer

# This is run on the server when a client has connected. 
func add_player(id: int):
	print("peer connecting %s" % id) 
	
	var adding_player = multiplayer_scene.instantiate()
	adding_player.player_id = id

	# for now, assume a node path in the map where we can add players
	var players_root = get_tree().get_current_scene().get_node("SpawnPoint")
	players_root.add_child(adding_player)

func rem_player(id: int):
	# for now, assume a node path in the map where we can add players
	var players_root = get_tree().get_current_scene().get_node("SpawnPoint")
	for player in players_root.get_children():
		if player.player_id == id:
			player.queue_free()
			print("peer disconnected %s" % id) 
			return
