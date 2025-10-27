extends BehaviourTreeAction

class_name SelectATargetAction

## Assuming we have a "targets" value in our blackboard, this action 

func tick(blackboard: BehaviourTreeBlackboard):
	var targets = blackboard.get_blackboard_value("targets")
	
	if not targets:
		return BehaviourTreeResult.Status.FAILURE
		
	# set current target to the first target in the blackboard
	blackboard.set_blackboard_value("current_target", targets[0])
