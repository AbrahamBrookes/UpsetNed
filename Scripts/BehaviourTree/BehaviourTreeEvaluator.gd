extends Node

class_name BehaviourTreeEvaluator

## Base class for creating your own evaluators in a behaviour tree.
## These will generally be classes that take a given blackboard value,
## run some logic on it, and return a score or status that the behaviour
## tree can use to make decisions. This is in the form of a float. Since
## blackboards are not really typesafe, and making them so seems like
## overkill, these classes will generally use type sniffing (ie: has_method,
## has_property, etc) to evaluate() their blackboard input.
## when you are creating evaluator nodes, name the node itself after its
## intended function, for instance if you are considering threat level
## you might consider: how tall is the enemy, how heavy is the enemy,
## how much damage can the enemy do, how fast can the enemy move, etc.
## So create a BehaviourTreeEvaluator node, name it "ThreatLevelEvaluator"
## and give it pre-made extended child nodes like "TargetHeightEvaluator",
## "TargetDamageEvaluator", "TargetSpeedEvaluator", etc that each return
## a float score based on the blackboard input.

# a reference that gets set by the behaviour tree on ready
var behaviour_tree: BehaviourTree

# allow skipping of children via a "dont_tick" property on them
@export var dont_tick: bool = false

func evaluate(_blackboard: BehaviourTreeBlackboard) -> float:
	# Override this method in subclasses to implement specific evaluation logic.
	# Return a float score based on the blackboard input.
	push_error("BehaviourTreeEvaluator: evaluate() not implemented!")
	return 0.0
