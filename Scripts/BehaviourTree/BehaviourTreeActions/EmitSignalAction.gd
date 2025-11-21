extends BehaviourTreeAction

class_name EmitSignalAction

## When this node is ticked it emits a signal, which you can hook up in the editor

signal emit

func _tick(_blackboard: BehaviourTreeBlackboard) -> int:
	emit_signal("emit")
	return BehaviourTreeResult.Status.SUCCESS
