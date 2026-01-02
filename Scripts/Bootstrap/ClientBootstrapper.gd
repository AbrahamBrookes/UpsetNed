extends Node

## The ClientBootstrapper handles booting the client side app. This runs when
## the game is _not_ a server, and is running on a players computer. This class
## loads up the game start UI and other scripts take it from there.
class_name ClientBootstrapper

# bootstrap services
func boot() -> void:
	print("bootstrapping client app")
