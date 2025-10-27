extends BehaviourTreeAction

class_name AttackTargetAction

## Given a state, this action will flip to it once it is reached in the tree

@export var blackboard_key_to_attack: String = "current_target"

# on ready, if the ChangeState signal is not connected, warn
func _ready():
	if not ChangeState.has_connections():
		push_warning("AttackTargetAction: ChangeState signal is not connected! Can not run attack action")

func tick(blackboard: BehaviourTreeBlackboard):
	var target = blackboard.get_blackboard_value(blackboard_key_to_attack, null)
	
	if not target:
		push_warning("AttackTargetAction: No target found in blackboard!")
		return BehaviourTreeResult.Status.FAILURE

	if not target is Node3D:
		push_warning("AttackTargetAction: Target is not a Node3D!")
		return BehaviourTreeResult.Status.FAILURE
	
	# change state to Attack, passing the target as extra data
	ChangeState.emit("Attack", target)
	return BehaviourTreeResult.Status.RUNNING
