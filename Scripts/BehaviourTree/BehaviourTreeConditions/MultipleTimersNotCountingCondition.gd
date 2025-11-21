extends BehaviourTreeCondition

class_name MultipleTimersNotCountingCondition

## Given an array of timers, if any of them are currently counting, return
## FAILURE, else SUCCESS, effectively waiting for the timers to run down.
## Invert with an inversion decorator if you need.
## The "Collate" flag denotes if we want to wait for _all_ timers or just one

## The timers that we are inspecting for running state
@export var timers: Array[Timer] = []

## If collate is true then we need _all_ timers to be stopped
@export var collate: bool

func _tick(_blackboard: BehaviourTreeBlackboard) -> int:
	for timer in timers:
		if not timer:
			push_error("All elements in timers array must be Timer nodes")
			return BehaviourTreeResult.Status.FAILURE
			
		if timer.is_stopped():
			if debug_log:
				print("Timer %s is stopped" % timer.name)
			# if not collating, we can return success as soon as one timer is stopped
			if not collate:
				return BehaviourTreeResult.Status.SUCCESS
		else:
			if debug_log:
				print("Timer %s is running" % timer.name)
			# if collating, we can return failure as soon as one timer is running
			if collate:
				return BehaviourTreeResult.Status.FAILURE
		
	# if we get here, either all timers are stopped (collate) or all are running (not collate)
	if collate:
		return BehaviourTreeResult.Status.SUCCESS
	else:
		return BehaviourTreeResult.Status.FAILURE
