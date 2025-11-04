extends BehaviourTreeCondition

class_name DistanceToPathTargetCondition

## Our PathTo state tracks its distance to the goal (as the noclip
## crow flies) and this condition simply checks that is above x

@export var distance: float = 0

func _tick(_blackboard: BehaviourTreeBlackboard) -> int:
	if behaviour_tree.state_machine.is_in_states(["PathTo"]):
		if "distance_to_goal" in behaviour_tree.state_machine.current_state:
			if behaviour_tree.state_machine.current_state.distance_to_goal > distance:
				return BehaviourTreeResult.Status.SUCCESS
	
	# else
	return BehaviourTreeResult.Status.FAILURE 
