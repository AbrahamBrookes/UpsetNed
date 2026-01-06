extends Node

## This script is the main entrypoint into our game. It is coupled to a "Main"
## Scene which is the default scene that launches when you load up the game and
## that scene stays active for the entire time the game is running.
##
## When our game launches it might be either a server (if it was run with the
## --headless flag) or a client (if it was not run with the --headless flag).
## The way Godot handles multiplayer is to run the same binary for both client
## and server, and rely on node tree similarities for synchronization. This is a
## nifty system, but we don't want to pollute our scripts with conditionals that
## check for server vs client. So this Main script effectively isolates all those
## conditionals down to one. We check if we are headles and then load in all the
## server stuff. If we are not headless we load in all the client stuff. This way
## we can write separate code for client and server, and have a "shared" node that
## handles RPC calls to talk between both.

class_name Main

# Our bootstrappers
@export var server_bootstrapper: ServerBootstrapper
@export var client_bootstrapper: ClientBootstrapper

# the world root node that we load and unload maps into
@export var world_root: Node

# Dependency injection for testability
var display_server_provider := DisplayServer

func _ready() -> void:
	# check for headless mode and bootstrap either the server or the client
	if Util.running_as_server():
		bootstrap_server()
	else:
		bootstrap_client()

# Bootstrapping the server means loading up a map and waiting
func bootstrap_server():
	server_bootstrapper.boot()

func bootstrap_client():
	client_bootstrapper.boot()
	
