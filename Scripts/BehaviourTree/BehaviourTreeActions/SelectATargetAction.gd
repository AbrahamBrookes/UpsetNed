extends BehaviourTreeAction

class_name SelectATargetAction

## Assuming we have a "targets" value in our blackboard, this action 

func tick(blackboard: BehaviourTreeBlackboard):
	# set current target to the first target in the blackboard
	blackboard.set_blackboard_value("current_target", blackboard.get_blackboard_value("targets")[0])
