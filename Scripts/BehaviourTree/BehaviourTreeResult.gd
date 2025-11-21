extends RefCounted
class_name BehaviourTreeResult

## Global behavior tree result constants
enum Status {
	FAILURE,
	SUCCESS,
	RUNNING,
	NOTHING # if we want to continue executing the tree, return NOTHING
}
