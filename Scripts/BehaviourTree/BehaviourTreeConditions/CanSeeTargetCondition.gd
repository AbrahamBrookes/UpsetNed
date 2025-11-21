extends BehaviourTreeCondition

class_name CanSeeTargetCondition

## This condition will periodically check for LOS between the owner and
## the target if we have one. This is optimized so it only checks at set
## intervals instead of every tick.

@export var blackboard_key: String = 'current_target'

# how often to check LOS (seconds)
@export var check_interval: float = 0.2
# what layers to check for occlusion
@export var collision_mask: int = 1
# how far the player should have moved from the last know location before we bother raycasting again
@export var movement_threshold: float = 0.5
# the direction the owner is facing, for field of view checks
@export var head: Node3D

var last_check_time: float = 0.0
var last_known_target_position: Vector3 = Vector3.ZERO
var can_see_target: BehaviourTreeResult.Status = BehaviourTreeResult.Status.FAILURE

# cache the owner as it won't change
@export var thinker: Node3D
# the target will change but lets make it a property for access
var target: Node3D

func _tick(blackboard: BehaviourTreeBlackboard) -> int:
	# if we haven't cached the owner yet, do so now
	if not thinker:
		thinker = owner

	target = blackboard.get_blackboard_value(blackboard_key, null)

	if not target or not thinker:
		# something is wrong, we can't see them
		return BehaviourTreeResult.Status.FAILURE
	
	# if not enough time has passed to check again, return cached result
	var current_time = Time.get_ticks_msec()
	if current_time - last_check_time < check_interval:
		return can_see_target

	# if the target has not moved enough, return cached result
	var distance_moved = target.global_position.distance_squared_to(last_known_target_position)
	if distance_moved < movement_threshold * movement_threshold:
		return can_see_target

	# if the head is not looking in the general direction of the target, fail early
	var to_target = (target.global_position - head.global_position).normalized()
	var head_forward = head.global_transform.basis.z.normalized()
	if head_forward.dot(to_target) < 0.5:
		return BehaviourTreeResult.Status.FAILURE

	# otherwise we're ready to do the expensive raycast check

	# perform raycast to check LOS
	if _perform_raycast_check():
		can_see_target = BehaviourTreeResult.Status.SUCCESS
	else:
		can_see_target = BehaviourTreeResult.Status.FAILURE

	# record last checked time 
	last_check_time = current_time
	
	return can_see_target

# perform the LOS check via raycast
func _perform_raycast_check() -> bool:
	# don't look at origins as they are in the floor. instead, look at center of aabb
	var local_aabb: AABB = target.get_aabb()
	var target_center: Vector3 = local_aabb.position + (local_aabb.size * 0.5) + target.global_position
	
	# no idea what this shit means, thanks Claude!
	var space_state = thinker.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		head.global_position,
		target_center
	)
	query.exclude = [head, thinker]
	query.collision_mask = collision_mask
	
	var result = space_state.intersect_ray(query)
	
	if behaviour_tree and behaviour_tree.debug and debug_log:
		DebugDraw3D.draw_line(head.global_position, target_center, Color(1, 1, 0))
	
	return result.is_empty() or result.collider == target
