extends Node

class_name BehaviourTreeEvaluatorGate

## The BehaviourTreeEvaluatorGate is single branch in conditional logic.
## You give it a BehaviourTreeEvaluator as a child node and assign it a
## lfoat value for @export threshold. When ticked, it evaluates the child
## evaluator and if the returned score is >= threshold, it returns SUCCESS
## which ticks back up to its selector or sequence node parent as a normal
## BehaviourTree node would and so its next sibling node can be ticked.

# a reference that gets set by the behaviour tree on ready
var behaviour_tree: BehaviourTree

# The threshold score to pass
@export var threshold: float = 0.5

# allow skipping of children via a "dont_tick" property on them
@export var dont_tick: bool = false

func tick(blackboard: BehaviourTreeBlackboard) -> int:
	# get the evaluator child node
	var evaluator: BehaviourTreeEvaluator = get_child(0) as BehaviourTreeEvaluator
	if not evaluator:
		push_error("BehaviourTreeEvaluatorGate: No evaluator child found!")
		return BehaviourTreeResult.Status.FAILURE
	
	# evaluate the child
	var score: float = evaluator.evaluate(blackboard)
	
	# compare to threshold
	if score >= threshold:
		return BehaviourTreeResult.Status.SUCCESS
	else:
		return BehaviourTreeResult.Status.FAILURE
