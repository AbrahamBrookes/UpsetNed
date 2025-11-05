extends State

## Prone means just laying there not moving.

@export var lookAtTarget: Node3D

# a target to look at
@export var target: Node3D

@export var mesh: Node3D

func Enter(_extra_data = null):
	# zero out the blend on locomote to get the idle animation
	state_machine.anim_tree.set("parameters/Locomotion/Locomote/blend_position", Vector2(0.0, 0.0))
	
	# stop all movement
	state_machine.locomotor.velocity = Vector3.ZERO

func Physics_Update(_delta: float):
	if not state_machine or not state_machine.locomotor:
		return

	if not target or not mesh:
		return

	var to_target: Vector3 = target.global_transform.origin - state_machine.locomotor.global_transform.origin
	to_target.y = 0.0
	if to_target.length_squared() <= 0.0001:
		return

	var local_dir: Vector3 = (mesh.global_transform.basis.inverse() * to_target).normalized()
	var blend_value := Vector2(-local_dir.x, local_dir.z)
	state_machine.anim_tree.set("parameters/Locomotion/Prone/blend_position", blend_value)
	
