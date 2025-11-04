extends BehaviourTreeAction

class_name PatrolAction

## This action holds a reference to a cluster of PatrolWaypoints. It
## handles to logic for selecting a waypoint and moving to it.

# the list of waypoints to patrol between
@export var patrol_waypoints: Array[Node3D] = []
# the destination waypoint we are currently moving towards
var current_waypoint: Node3D = null
# the waypoint we just came from
var previous_waypoint: Node3D = null
# the one before that, just so we don't go back and forth
var pre_previous_waypoint: Node3D = null

# the shortest and longest times we should wait between patrols, to be randomized
@export var min_wait_time: float = 1.0
@export var max_wait_time: float = 3.0
# and the timer we will use
@export var wait_timer: Timer
# have we waited?
var has_waited: bool = false
# shall we wait?
var shall_wait: bool = false

func _ready(_delta = null):
	if patrol_waypoints.size() < 3:
		push_error("PatrolAction: Not enough patrol waypoints set - we need at least 3!")

	# connect the wait timer timeout signal
	wait_timer.timeout.connect(_on_WaitTimer_timeout)

# when the timer ends, we have waited
func _on_WaitTimer_timeout():
	has_waited = true

func _tick(_blackboard: BehaviourTreeBlackboard) -> int:
	# if the state machine is currently PathingTo, just return RUNNING
	if behaviour_tree.state_machine.is_in_states(["PathTo"]):
		shall_wait = true
		print("already in path to")
		return BehaviourTreeResult.Status.RUNNING

	# if we have flicked over to Idle then we should start a new patrol leg
	if behaviour_tree.state_machine.is_in_states(["Idle"]):
		# if we are to wait, start the wait timer
		if shall_wait:
			print("flicking shall_wait off")
			shall_wait = false
			has_waited = false
			var wait_time = randf_range(min_wait_time, max_wait_time)
			wait_timer.start(wait_time)
			return BehaviourTreeResult.Status.RUNNING
			
	# the next time this gets ticked, we will be waiting - the timeout signal will set has_waited to true
	if not has_waited:
		# make sure we are running the timer
		if wait_timer.is_stopped():
			wait_timer.start()
		return BehaviourTreeResult.Status.RUNNING
		
	# once the timeout signal flicks has_waited to true, we can start a new patrol leg
	return start_new_patrol_leg()


# start a new patrol leg to a random waypoint
func start_new_patrol_leg() -> int:
	print("starting a new leg")
	# we have waited, so reset the flag
	has_waited = false
	
	var available_waypoints = patrol_waypoints.duplicate()
	if previous_waypoint:
		available_waypoints.erase(previous_waypoint)
	if pre_previous_waypoint:
		available_waypoints.erase(pre_previous_waypoint)
	if current_waypoint:
		available_waypoints.erase(current_waypoint)
	# pick a random one from the remaining
	current_waypoint = available_waypoints[randi() % available_waypoints.size()]

	if not current_waypoint:
		push_warning("PatrolAction: No valid waypoint found!")
		return BehaviourTreeResult.Status.FAILURE

	if not current_waypoint is Node3D:
		push_warning("PatrolAction: Current waypoint is not a Node3D!")
		return BehaviourTreeResult.Status.FAILURE

	# change state to Patrol, passing the waypoint as extra data
	behaviour_tree.state_machine.TransitionTo("PathTo", {
		"navigation_goal": current_waypoint.global_position
	})
	return BehaviourTreeResult.Status.SUCCESS
