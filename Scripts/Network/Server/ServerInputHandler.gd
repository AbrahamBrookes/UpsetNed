extends Node3D

## On the server we don't apply input straight away, we cache it and then apply
## it in order on the next physics tick. This node only runs on the server and
## caches incoming inputs and then applies them in it's physics tick
class_name ServerInputHandler

## the input frames per player that we have cached
# peer_id -> Array[InputPacket]
var input_queues: Dictionary = {}

# peer_id -> InputPacket (last simulated input)
var last_input: Dictionary = {}

## A reference back to the server node
@export var server: Server

## we cache the location of all players for a set number of ticks, so we can
## roll back inputs and compare shooting events
var history := {} # tick -> Transform3D
const HISTORY_TICKS := 60 * 1 # 1s at 60hz

## in physics process, simulate and then acknowledge each input frame per player
func _physics_process(_delta: float):
	for peer_id in input_queues.keys():
		var player: DeterministicPlayerCharacter = server.get_player(peer_id)
		if not player:
			continue

		var queue: Array[InputPacket] = input_queues.get(peer_id)
		var input: InputPacket
		
		if queue != null and queue.size() > 0:
			# Consume exactly ONE input per tick
			input = queue.pop_front()
			last_input[peer_id] = input
		else:
			# Reuse last input (held input continues)
			input = last_input.get(peer_id)
			if input == null:
				continue # nothing to simulate yet

		# Simulate once per tick
		player.input_synchronizer.apply_input_packet(input)
		
		# cache in our history ringbuffer
		record_history(peer_id, player.global_transform)

		# Send authoritative snapshot
		send_authoritative_state(peer_id, player, input)

## When we receive an input packet from a client we need to cache it so that we
## can process it on the next server tick
func cache_input(peer_id: int, input: InputPacket) -> void:
	if not input_queues.has(peer_id):
		input_queues[peer_id] = [] as Array[InputPacket]
	input_queues[peer_id].append(input)

## When we move all the pawns on the board, we cache their locations for playback
func record_history(peer_id: int, location: Transform3D) -> void:
	var arr: Array = history.get(peer_id, [])
	# if we haven't run yet, set our array size
	if arr.is_empty():
		arr.resize(HISTORY_TICKS)
	# record the tick and their location - using divisor to create a ringbuffer
	arr[Network.server.server_tick % HISTORY_TICKS] = location
	# stash this history slide in the players filing cabinet drawer
	history[peer_id] = arr
	
## In order to send the authoritative state we need to gather up the data to sync
## back to the client and then rpc it on them
func send_authoritative_state(peer_id: int, player: DeterministicPlayerCharacter, input: InputPacket):
	# prepare an AuthoritativeState
	var state = AuthoritativeState.new(
		input.seq,
		player.global_position,
		player.mesh.rotation,
		player.velocity,
		player.mouselook.camera_pivot.rotation,
		player.grounded
	)
	
	# send it back to the client
	Network.send_authoritative_state.rpc_id(peer_id, state.to_dict())
	
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
	
