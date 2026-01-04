extends Node

## On the server we don't apply input straight away, we cache it and then apply
## it in order on the next physics tick. This node only runs on the server and
## caches incoming inputs and then applies them in it's physics tick
class_name ServerInputHandler

## the input frames per player that we have cached - this is the last input we
## received for each player, we overwrite them as they come in
var input_cache: Dictionary[int, InputPacket]

## A reference back to the server node
@export var server: Server

## in physics process, simulate and then acknowledge each input frame per player
func _physics_process(delta):
	for peer_id in input_cache.keys():
		var input_packet: InputPacket = input_cache[peer_id]
		
		# get the server instance of the player
		var player: DeterministicPlayerCharacter = server.get_player(peer_id)
		if not player:
			continue
		
		# apply the input packet to that player
		player.input_synchronizer.apply_input_packet(input_packet, delta)
		
		# send their authoritative state back to them
		send_authoritative_state(peer_id, player, input_packet)
	
	# clear the cache after processing
	input_cache.clear()

## In order to send the authoritative state we need to gather up the data to sync
## back to the client and then rpc it on them
func send_authoritative_state(peer_id: int, player: DeterministicPlayerCharacter, input: InputPacket):
	# prepare an AuthoritativeState
	var state = AuthoritativeState.new(
		input.seq,
		player.global_position,
		player.mesh.rotation,
		player.velocity
	)
	
	# send it back to the client
	Network.send_authoritative_state.rpc_id(peer_id, state.to_dict())
