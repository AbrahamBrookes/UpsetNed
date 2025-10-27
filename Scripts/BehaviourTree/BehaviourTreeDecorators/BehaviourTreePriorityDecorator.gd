extends Node

class_name BehaviourTreePriorityDecorator

## the BehaviourTreePriorityDecorator is assigned an integer index. It ticks its child
## BehaviourTreePrioritiser node to get an ordered list of evaluator names or IDs. It then
## selects the evaluator at the assigned index from that list and assigns it to the given
## blackboard value key. If there is no evaluator at that index, it returns FAILURE.

# the blackboard key to save the selected evaluator name or ID to
@export var blackboard_key_to_set: String = "curent_target"

# the index to select from the prioritiser's ordered list
@export var index: int = 0

func tick(blackboard: BehaviourTreeBlackboard) -> int:
	# get the prioritiser child node
	var prioritiser: BehaviourTreePrioritiser = get_child(0) as BehaviourTreePrioritiser
	if not prioritiser:
		push_error("BehaviourTreePriorityDecorator: No prioritiser child found!")
		return BehaviourTreeResult.Status.FAILURE
	
	# tick the prioritiser to get the ordered list
	var ordered_list: Array = prioritiser.tick(blackboard)
	
	# check if the index is valid
	if index >= 0 and index < ordered_list.size():
		var selected_evaluator = ordered_list[index]
		# save the selected evaluator to the blackboard
		blackboard.set_blackboard_value(blackboard_key_to_set, selected_evaluator)
		return BehaviourTreeResult.Status.SUCCESS
	else:
		return BehaviourTreeResult.Status.FAILURE
