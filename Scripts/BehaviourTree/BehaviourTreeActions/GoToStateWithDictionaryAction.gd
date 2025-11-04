extends BehaviourTreeAction

class_name GoToStateWithDictionaryAction

## Given a state and a dictionary, this action will flip to that state and pass
## the dictionary as extra data once it is reached in the tree

# the state name to transition to
@export var state_name: String
@export var dictionary_data: Dictionary
# on ready, if the ChangeState signal is not connected, warn
func _ready():
	if not ChangeState.has_connections():
		push_warning("GoToStateWithBlackboardValueAction: ChangeState signal is not connected! Can not run action")
	
	if not state_name:
		push_warning("GoToStateWithBlackboardValueAction: no state name given, what should we transition to?")

func _tick(_blackboard: BehaviourTreeBlackboard):
	if not dictionary_data:
		push_warning("GoToStateWithBlackboardValueAction: No value found in blackboard!")
		return BehaviourTreeResult.Status.FAILURE
	
	# change state to the given state, passing the data as extra data
	ChangeState.emit(state_name, dictionary_data)
	return BehaviourTreeResult.Status.SUCCESS
