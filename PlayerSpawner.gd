extends MultiplayerSpawner

## In order to replicate stuff on the spawned node, we ware going to use a custom
## spawn function on our player spawner
class_name PlayerSpawner

func _ready() -> void:
	spawn_function = _spawn_player

# configure the player and return them for spawning
func _spawn_player(data: Dictionary) -> Node:
	var player := preload("res://PlayerCharacter/PlayerCharacter.tscn").instantiate()
	player.name = str(data.peer_id)
	player.global_transform = data.transform
	player.input_synchronizer.set_multiplayer_authority(data.peer_id)
	return player

func _on_spawned(node: Node) -> void:
	node = node as DeterministicPlayerCharacter
	if not node:
		return

	# if we are the authority on this node, use its camera
	if node.input_synchronizer.is_multiplayer_authority():
		PlayerRegistry.set_local_player(node)
