extends Node

class_name BehaviourTreeAction

## A BehaviourTreeAction is an action that an AI agent can perform.
## It may have children as decorators to modify its behavior.
## The parent node is typically a sequence or selector that determines
## when this action is executed.
## In our game, Actions will generally emit signals as opposed to calling
## a function on some other node. When you configure a behavior tree and
## state machine, you will generally hook up a BehaviourTreeAction node's
## signal to the state machines travelTo method in order to cause a state
## change. The states themselves update the blackboard values which then
## influences the behaviour tree.

# Actions emit a signal with parameters - this is automatically be hooked
# up to the StateMachines TravelTo method by the BehaviourTree node
signal ChangeState(state_name: String, extra_data: Dictionary)

# Actions can update blackboard values by emitting this signal
signal UpdateBlackboardValue(key: String, value: Variant)

# a reference that gets set by the behaviour tree on ready
var behaviour_tree: BehaviourTree

func tick(_blackboard: BehaviourTreeBlackboard) -> int:
	# Override this method in subclasses to implement specific action logic.
	# Return SUCCESS if the action completed successfully,
	# FAILURE if the action failed,
	# or RUNNING if the action needs more time to complete.
	push_error("BehaviourTreeAction: tick() not implemented!")
	return BehaviourTreeResult.Status.FAILURE
