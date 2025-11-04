extends BehaviourTreeAction

class_name DebugPrintAction

## Just prints to debug, for testing actions

@export var to_print: String

func _tick(_blackboard: BehaviourTreeBlackboard):
	print(to_print)
	return BehaviourTreeResult.Status.SUCCESS
