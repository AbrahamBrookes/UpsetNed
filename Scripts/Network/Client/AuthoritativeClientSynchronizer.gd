extends Node3D

## The AuthoritativeClientSynchronizer is used for players to send their position
## rotation etc back to the server, and, in the case of remote players syncing
## to the local instance, and the server syncing to clients, updating the position
## rotation etc of a remote player (to the server, all players are remote players)
class_name AuthoritativeClientSynchronizer

## Gather the local ClientAuthoritativeState and send it to the server
func send_state_to_server():
	## get the local player if any
	var local_player : DeterministicPlayerCharacter = PlayerRegistry.local_player as DeterministicPlayerCharacter
	if not local_player: 
		return
	
	# states can override animations, and PlayerPawn just wants the animation name
	var animation = local_player.state_machine.current_state.animation_override
	if not animation:
		animation = local_player.state_machine.current_state.name
	var locomotion_blendspace: Vector2 = local_player.state_machine.anim_tree.get("parameters/Locomotion/Locomote/blend_position")
		
	var state: Dictionary = ClientAuthoritativeState.new(
		Network.server.server_tick,
		local_player.global_position,
		local_player.mesh.global_rotation,
		animation,
		locomotion_blendspace
	).to_dict()
	Network.client_send_state.rpc_id(1, state)
