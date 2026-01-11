extends Node

## This is an autoload that is only used on the client to register the currently
## active player node for easy access

var local_player: DeterministicPlayerCharacter = null

var remote_players: Dictionary # [peer_id: DeterministicPlayerCharacter]

func append_remote_player(player: Node3D) -> void:
	push_error(player.name)
	# don't append the local player
	if local_player and player.name == local_player.name:
		return
	# assuming the peer_id is being set as the name - see PlayerSpawner.gd
	remote_players.set(player.name, player)

func set_local_player(player: DeterministicPlayerCharacter):
	local_player = player
	
	# also set the camera to active
	local_player.camera.make_current()

func clear_local_player(player):
	if local_player == player:
		local_player = null

func get_remote_player(player_id: StringName):
	if not remote_players.has(player_id):
		return null
		
	return remote_players.get(player_id)

# get a player by id wether remote or local
func get_player(player_id: int) -> Node3D:
	if local_player and local_player.name == str(player_id):
		return local_player
	# else
	return remote_players.get(str(player_id))

# remove a player from our own list
func remove_player(player_id: int):
	if local_player.name == str(player_id):
		local_player = null
		return
	# else
	remote_players.erase(str(player_id))
	
	
