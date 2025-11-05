extends Node

## Enemies don't have a human manipulating a mouse to look around the map.
## However, they might be targeting and that informs which way they are
## looking. Since we are using a blendspace setup to emulate looking in a
## direction, we need to make this work for the enemy in a similar way to 
## the player, as they use the same anim tree etc

class_name BlendLook

@export var target: Node3D
@export var mesh: Node3D
@export var state_machine: StateMachine

func _physics_process(delta: float) -> void:
	var to_target: Vector3 = target.global_transform.origin - owner.global_transform.origin
	to_target.y = 0.0
	if to_target.length_squared() <= 0.0001:
		return

	var local_dir: Vector3 = (mesh.global_transform.basis.inverse() * to_target).normalized()
	var blend_value := Vector2(-local_dir.x, local_dir.z)
	state_machine.anim_tree.set("parameters/Locomotion/Sliding/blend_position", blend_value)
	state_machine.anim_tree.set("parameters/Locomotion/Prone/blend_position", blend_value)
	state_machine.anim_tree.set("parameters/Locomotion/Stunting/blend_position", blend_value)
	state_machine.anim_tree.set("parameters/Locomotion/Diving/blend_position", blend_value)
	state_machine.anim_tree.set("parameters/Locomotion/DiveSlide/blend_position", blend_value)
	state_machine.anim_tree.set("parameters/Locomotion/DiveProne/blend_position", blend_value)
	# aim blend spaces to fake IK
	state_machine.anim_tree.set("parameters/StandingAimRHandBlendSpace/blend_position", blend_value)
	state_machine.anim_tree.set("parameters/StandingAimLHandBlendSpace/blend_position", blend_value)
	state_machine.anim_tree.set("parameters/SlidingAimRHandBlendSpace/blend_position", blend_value)
	state_machine.anim_tree.set("parameters/SlidingAimLHandBlendSpace/blend_position", blend_value)
	
