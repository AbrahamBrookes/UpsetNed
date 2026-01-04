extends Node

## This is an autoload that is only used on the client to register the currently
## active player node for easy access

var local_player: DeterministicPlayerCharacter = null

func set_local_player(player):
	local_player = player
	
	# also set the camera to active
	local_player.camera.make_current()

func clear_local_player(player):
	if local_player == player:
		local_player = null
