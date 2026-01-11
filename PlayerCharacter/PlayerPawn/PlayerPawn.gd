extends Node3D

## The PlayerPawn is just the doll body for moving a character visually around
## the map. It has no collision and no logic, it is purely a puppet on strings
## being towed around the map by the server
class_name PlayerPawn

# since we are rotating the mesh separately we need a reference to it
@export var mesh: Node3D
# the animation player, for direct fenagling
@export var animation_player: AnimationPlayer
# child scripts and the state machine require a reference to the anim tree
@export var anim_tree : AnimationTree
# playback is the engine-level animation tree state machine
var playback: AnimationNodeStateMachinePlayback

## The current animation name in the animation tree. This animation tree is the
## same as the one in a PlayerCharacter so we can fenagle it locally to get the
## same output from state frames sent to us by the authoritative client
@export var current_state: StringName

# If we spawn as the local player we'll want to spawn a PlayerCharacter instead
var local_player_scene = load("res://PlayerCharacter/PlayerCharacter.tscn")

# Otherwise we spawn the Pawn scene
var remote_player_scene = load("res://PlayerCharacter/PlayerPawn/PlayerPawn.tscn")

func _ready():
	playback = anim_tree.get("parameters/Locomotion/playback")
	set_current_state("Locomote")

func set_current_state(state_name: StringName):
	if playback:
		playback.travel(state_name)
		current_state = state_name

## We are spawning this pawn on the server - one to represent each player. We need
## a central spawn method to set it up and add it to a scene
func spawn(peer_id, spawn_at: Vector3):
	# if we are spawning for the controlling peer, use the DeterministicPlayerCharacter
	if peer_id == multiplayer.get_unique_id():
		push_error("spawning DeterministicPlayerCharacter")
		var new_node = local_player_scene.instantiate() as DeterministicPlayerCharacter
		# set the name to the peer id for easy lookup
		new_node.name = str(peer_id)
		new_node.set_multiplayer_authority(peer_id)
		# attach them to the worldRoot node
		Network.client.world_root.add_child(new_node)
		# position them after adding them
		new_node.global_position = spawn_at
		# register it with the player registry
		PlayerRegistry.set_local_player(new_node)
	else:
		push_error("spawning PlayerPawn")
		# otherwise we want to spawn the pawn
		var new_node = remote_player_scene.instantiate()
		# set the name to the peer id for easy lookup
		new_node.name = str(peer_id)
		# attach them to the worldRoot node
		Network.client.world_root.add_child(new_node)
		# position them after adding them
		new_node.global_position = spawn_at
		# register a remote player with the player registry
		PlayerRegistry.append_remote_player(new_node)
		
