extends Node

## The ClientBootstrapper handles booting the client side app. This runs when
## the game is _not_ a server, and is running on a players computer. This class
## loads up the game start UI and other scripts take it from there.
class_name ClientBootstrapper

## the world root is where we load maps into
@export var world_root: Node

# bootstrap services
func boot() -> void:
	print("bootstrapping client app")
	
	# load up the main menu
	var main_menu = load("res://UI/MainMenu/MainMenu.tscn").instantiate()
	main_menu.name = "Main Menu"
	world_root.add_child(main_menu)
	
