extends Node

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

		# Send authoritative snapshot
		send_authoritative_state(peer_id, player, input)

## When we receive an input packet from a client we need to cache it so that we
## can process it on the next server tick
func cache_input(peer_id: int, input: InputPacket) -> void:
	if not input_queues.has(peer_id):
		input_queues[peer_id] = [] as Array[InputPacket]
	input_queues[peer_id].append(input)
	
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
