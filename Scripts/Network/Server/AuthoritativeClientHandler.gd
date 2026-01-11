extends Node3D

## the AuthoritativeClientHandler is the server side controller that receives the
## updates from the server and updates its local PlayerPawns
class_name AuthoritativeClientHandler

## we cache the location of all players for a set number of ticks, so we can
## roll back inputs and compare shooting events
var history := {} # tick -> Transform3D
const HISTORY_TICKS := 60 * 1 # 1s at 60hz

# a dictionary of peer_ids and their last known states
var states: Dictionary

## when a client sends us their state, apply it to our local pawn of them
func apply_authoritative_state(state: Dictionary, peer_id: StringName):
	var player = PlayerRegistry.get_remote_player(peer_id) as PlayerPawn
	
	# check we got a valid player
	if not player:
		## maybe spawn a new pawn
		#push_error("spawning PlayerPawn")
		## otherwise we want to spawn the pawn
		#var new_node = remote_player_scene.instantiate()
		## set the name to the peer id for easy lookup
		#new_node.name = str(peer_id)
		## attach them to the worldRoot node
		#world_root.add_child(new_node)
		## position them after adding them
		#new_node.global_position = position
		## register a remote player with the player registry
		#PlayerRegistry.append_remote_player(new_node)
		return
		
	# deserialize the state and apply it
	var parsed_state = ClientAuthoritativeState.from_dict(state)
	
	if not state:
		return

	## update the pawns position etc in the local simulation 
	# TODO: we'll lerp this between history frames later
	player.global_position = state.global_position
	player.mesh.global_rotation = state.rotation
	player.anim_tree.set("parameters/Locomotion/Locomote/blend_position", state.locomotion_blendspace)
	
	var next_state = state.current_state
	if player.current_state != next_state:
		player.set_current_state(next_state)
	
	# record the history for server playback
	record_history(peer_id, parsed_state)
	

## receive a list of authoritative states and apply them to your local players
func apply_authoritative_states(states: Dictionary):
	for player_id in states.keys():
		apply_authoritative_state(states.get(player_id), player_id)
		
		
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
	



## When we move all the pawns on the board, we cache their locations for playback
func record_history(peer_id: StringName, state: ClientAuthoritativeState) -> void:
	var arr: Array = history.get(peer_id, [])
	# if we haven't run yet, set our array size
	if arr.is_empty():
		arr.resize(HISTORY_TICKS)
	# record the tick and their location - using divisor to create a ringbuffer
	arr[Network.server.server_tick % HISTORY_TICKS] = state
	# stash this history slide in the players filing cabinet drawer
	history[peer_id] = arr
