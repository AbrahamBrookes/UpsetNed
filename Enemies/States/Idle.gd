extends State

## Idle means just standing there not moving.

@export var lookAtTarget: Node3D

func _ready() -> void:
	# we want to use the Locomote animation state
	animation_override = "Locomote"

func Enter(_extra_data = null):
	# zero out the blend on locomote to get the idle animation
	state_machine.anim_tree.set("parameters/Locomotion/Locomote/blend_position", Vector2(0.0, 0.0))
	
	# stop all movement
	state_machine.locomotor.velocity = Vector3.ZERO
