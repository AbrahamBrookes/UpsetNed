extends Node3D

## The AuthoritativeClientSynchronizer is used for players to send their position
## rotation etc back to the server, and, in the case of remote players syncing
## to the local instance, and the server syncing to clients, updating the position
## rotation etc of a remote player (to the server, all players are remote players)
class_name AuthoritativeClientSynchronizer

## we cache the location of all players for a set number of ticks, so we can
## roll back inputs and compare shooting events
var history := {} # tick -> Transform3D
const HISTORY_TICKS := 60 * 1 # 1s at 60hz

## Gather the local ClientAuthoritativeState and send it to the server
func send_state_to_server():
	var state: ClientAuthoritativeState = ClientAuthoritativeState.new()
	Network.client_send_state.rpc_id(1, state)

## receive a list of authoritative states and apply them to your local players
func apply_authoritative_states(states: Dictionary):
	for player_id in states.keys():
		var player = PlayerRegistry.get_remote_player(str(player_id)) as DeterministicPlayerCharacter
		
		# check we got a valid player
		if not player:
			continue
			
		# don't apply to our local player
		if player == PlayerRegistry.local_player:
			continue
			
		# deserialize the state and apply it
		var state = states.get(player_id)

		# lerp these values for smoothness
		# player.global_position = state.global_position
		# player.mesh.global_rotation = state.rotation
		# player.velocity = state.velocity
		player.global_position = player.global_position.lerp(state.global_position, 0.6)
		player.mesh.global_rotation = player.mesh.global_rotation.slerp(state.rotation, 0.6)
		player.velocity = player.velocity.lerp(state.velocity, 0.6)
		
		Network.server.server_tick = state.server_tick
		player.mouselook.camera_pivot.global_rotation = state.camera_rotation
		
		var next_state = player.state_machine.state_indexed_list.get(state.current_state)
		if player.state_machine.current_state.name != next_state.name:
			player.state_machine.flick(next_state.name)

## When we move all the pawns on the board, we cache their locations for playback
func record_history(peer_id: int, state: ClientAuthoritativeState) -> void:
	var arr: Array = history.get(peer_id, [])
	# if we haven't run yet, set our array size
	if arr.is_empty():
		arr.resize(HISTORY_TICKS)
	# record the tick and their location - using divisor to create a ringbuffer
	arr[Network.server.server_tick % HISTORY_TICKS] = state
	# stash this history slide in the players filing cabinet drawer
	history[peer_id] = arr

## When a player shoots their weapon on the client, they rcp player_shot_weapon
## on the Network, which back down to us, where we recreate the state at their
## server tick and do the hitscan ourselves
func player_shot_weapon(event: PlayerShotWeaponEvent, peer_id: int) -> void:
	var shoot_tick: int = event.server_tick
	
	# keep a list of original locations to flick back to after
	var original_locations: Dictionary = {} # [peer_id: transform3D]
	
	# loop through all players and roll back to the shoot tick
	for player_id in history.keys():
		var player_history: Array = history.get(player_id, [])
		if player_history.is_empty():
			continue # no history for this player
		
		# pluck the history for this player
		var location = player_history[shoot_tick % HISTORY_TICKS]
		if location == null:
			continue # no location recorded for this tick <- do something?
			
		#  get the player we are simulating on the server
		var player = Network.server.get_player(player_id)
		if not player:
			continue
		
		# cache their current position
		original_locations[player_id] = player.global_transform
		
		# apply the historic location
		player.global_transform = location

	# perform hitscan from the recorded location
	var query = PhysicsRayQueryParameters3D.create(event.shot_origin, event.shot_destination)
	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)
	if result:
		# We hit something, process hit (e.g. apply damage)
		var hit_position: Vector3 = result.position
		var hit_normal: Vector3 = result.normal
		var collider = result.collider
		
		#print("server", hit_position)
		
		var shot_receiver = collider.get_node_or_null("ShotReceiver") as ShotReceiver
		if shot_receiver:
			shot_receiver.receive_shot(hit_position, hit_normal)
		
		# Here you would apply damage or other effects to the collider if it's a valid target
	
	# Then roll all the player locations back
	for player_id in history.keys():
		var player = Network.server.get_player(player_id)
		if not player:
			return
		# put them back to their original locations
		player.global_transform = original_locations[player_id]
	
