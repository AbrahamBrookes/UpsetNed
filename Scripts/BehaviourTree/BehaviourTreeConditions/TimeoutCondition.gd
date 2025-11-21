extends BehaviourTreeCondition

class_name TimeoutCondition

## A simple timeout - assign a timer, this node will return SUCCESS if the
## timer is not running, FAILURE if it is, effectively waiting for the timer
## to run down. Invert with an inversion decorator if you need

@export var timer: Timer

func _tick(_blackboard: BehaviourTreeBlackboard) -> int:
	if not timer:
		push_error("Must assign a Timer node to TimeoutCondition")
		return BehaviourTreeResult.Status.FAILURE
	
	if timer.is_stopped():
		return BehaviourTreeResult.Status.SUCCESS
	else:
		return BehaviourTreeResult.Status.FAILURE
