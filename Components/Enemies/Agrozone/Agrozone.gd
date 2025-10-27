extends Area3D

class_name Agrozone

## The agrozone is a blackboard component used for enemy logic. It is a drag and
## drop component that contains an area and a reference to a blackboard. Pretty
## simply, when a body enters the agrozone this script updates the "targets"
## value of the related blackboard so that the behaviour tree becomes aware
## of the target.
## Since this is an Area3D node, it emits a signal to itself and when you drop
## it into a scene you can add a collision shape and set up the collision layers
## yourself.

# the blackboard to update
@export var blackboard: BehaviourTreeBlackboard

# when a body enters the zone, blindly add it to targets (assuming collision layers are set up correctly)
func _on_body_entered(body: Node3D) -> void:
	var targets = blackboard.get_blackboard_value("targets", [])
	
	# if the target is not in the list, add it
	if body not in targets:
		targets.append(body)
		blackboard.set_blackboard_value("targets", targets)

# when a body exits the zone, remove it from targets
func _on_body_exited(body: Node3D) -> void:
	var targets = blackboard.get_blackboard_value("targets", [])
	if body in targets:
		targets.erase(body)
		blackboard.set_blackboard_value("targets", targets)
