extends BehaviourTreeAction

class_name GoToStateWithBlackboardValueAction

## Given a state anda  blackboard key, this action will flip to that state and pass
## the blackboard value as extra data once it is reached in the tree

# the state name to transition to
@export var state_name: String
@export var blackboard_key_to_send: String = "current_target"

# on ready, if the ChangeState signal is not connected, warn
func _ready():
	if not ChangeState.has_connections():
		push_warning("GoToStateWithBlackboardValueAction: ChangeState signal is not connected! Can not run action")
	
	if not state_name:
		push_warning("GoToStateWithBlackboardValueAction: no state name given, what should we transition to?")

func tick(blackboard: BehaviourTreeBlackboard):
	var data = blackboard.get_blackboard_value(blackboard_key_to_send, null)
	
	if not data:
		push_warning("GoToStateWithBlackboardValueAction: No value found in blackboard!")
		return BehaviourTreeResult.Status.FAILURE
	
	# change state to the given state, passing the data as extra data
	ChangeState.emit(state_name, data)
	return BehaviourTreeResult.Status.RUNNING
