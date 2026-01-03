extends Node

## The ClientBootstrapper handles booting the client side app. This runs when
## the game is _not_ a server, and is running on a players computer. This class
## loads up the game start UI and other scripts take it from there.
class_name ClientBootstrapper

## the world root is where we load maps into
@export var world_root: Node

## the main menu node
var main_menu: MainMenu

# bootstrap services
func boot() -> void:
	push_error("bootstrapping client app")
	
	# load up the main menu
	main_menu = load("res://UI/MainMenu/MainMenu.tscn").instantiate()
	main_menu.name = "Main Menu"
	world_root.add_child(main_menu)
	
	# listen to events
	main_menu.play_button_pressed.connect(join_server)

# when the player joins a server _that's_ when we set up the client peer.
# right now we have hardcoded the IP and port in the button press
func join_server(ip: String, port: int) -> void:
	# tear down the main menu
	main_menu.queue_free()
	
	# create a multiplayer peer
	var client_peer = ENetMultiplayerPeer.new()
	# make it a client connecting to the server ip and port
	client_peer.create_client(ip, port)
	# pass it to the built in multiplayer API so this instance of the game
	# will know it is a client, not a server
	multiplayer.multiplayer_peer = client_peer
	
	# the ServerBootstrapper has set up a server and will listen to the
	# peer_connected signal and then use the network node to RPC the
	# ClientBootstrapper.load_map method to have the client load the map
	# when it connects to that standalone server
	
	
	
