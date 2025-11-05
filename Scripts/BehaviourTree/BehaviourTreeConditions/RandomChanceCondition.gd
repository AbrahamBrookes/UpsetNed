extends BehaviourTreeCondition

## A condition for configuring randomness into a tree

class_name RandomChanceCondition

# a float value to compare against the random value
@export var limit: float = 0.5

# a result to return if the limit is above the random value
@export var result_when_rand_above_limit: BehaviourTreeResult.Status = BehaviourTreeResult.Status.SUCCESS

# a result to return if the limit is above the below value
@export var result_when_rand_below_limit: BehaviourTreeResult.Status = BehaviourTreeResult.Status.FAILURE

func _tick(_blackboard: BehaviourTreeBlackboard) -> int:
	# generate a random number 0.0 - 1.0
	var rand_value = randf()
	print(rand_value)
	if rand_value <= limit:
		return result_when_rand_below_limit
	else:
		return result_when_rand_above_limit
