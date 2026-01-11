extends Node

## MouseLook handles readingt he mouse input and moving the camera around
class_name Mouselook

# bundled player camera
@export var camera: Camera3D
@export var camera_pivot: Node3D
@export var camera_target_offset: Vector3

# the node we rotate left and right
@export var mesh: Node3D

# we're going to drive animation values with the mouse
@export var anim_tree: AnimationTree

# a raycast for hitscan calculations
@export var raycast: RayCast3D

# an invisible node we place at the target so IK can point at it
@export var target_node: Node3D

# the shootin arm bone, for pointing at targets
@export var skeleton: Skeleton3D
@export var shootin_arm_bone_name: String = "DEF-forearm.R"

# debug if ya wanna
@export var debug: bool = false

# a reference to the contorller input to get the mouse delta
@export var controller_input: ControllerInput

# check game preferences global for invert y
var invert_y = GamePreferences.invert_y

func _ready() -> void:
	if debug:
		target_node.visible = true
	
func mouseLook():
	# we have parameters/Locomotion/Sliding/blend_position which is 2d.
	# when the camera is looking left relative to the character, we want negative x, right positive x
	# when the camera is looking forward relative to the character, we want positive y, back negative y
	
	# the input synchronizer caches our mouse input
	var mouse_delta = controller_input.current_input.mouse_delta
	
	# Get the rotation difference between camera pivot and mesh
	var relative_rotation = camera_pivot.global_rotation.y - mesh.global_rotation.y
	
	# Normalize the angle to [-PI, PI] range
	while relative_rotation > PI:
		relative_rotation -= 2 * PI
	while relative_rotation < -PI:
		relative_rotation += 2 * PI
	
	# Convert the relative rotation to blend space coordinates
	# When mesh and camera are aligned (running): relative_rotation = 0, blend = (0, -1) 
	# When camera rotates relative to mesh (prone): blend changes based on relative angle
	var blend_value = Vector2(
		sin(relative_rotation),   # left/right: negative = left, positive = right
		-cos(relative_rotation)   # forward/back: negative = forward, positive = back
	)
	
	anim_tree.set("parameters/Locomotion/Sliding/blend_position", blend_value)
	anim_tree.set("parameters/Locomotion/Prone/blend_position", blend_value)
	anim_tree.set("parameters/Locomotion/Stunting/blend_position", blend_value)
	anim_tree.set("parameters/Locomotion/Diving/blend_position", blend_value)
	anim_tree.set("parameters/Locomotion/DiveSlide/blend_position", blend_value)
	anim_tree.set("parameters/Locomotion/DiveProne/blend_position", blend_value)
	# aim blend spaces to fake IK
	anim_tree.set("parameters/StandingAimRHandBlendSpace/blend_position", blend_value)
	anim_tree.set("parameters/StandingAimLHandBlendSpace/blend_position", blend_value)
	anim_tree.set("parameters/SlidingAimRHandBlendSpace/blend_position", blend_value)
	anim_tree.set("parameters/SlidingAimLHandBlendSpace/blend_position", blend_value)
	anim_tree.set("parameters/DivingAimRHandBlendSpace/blend_position", blend_value)
	anim_tree.set("parameters/DivingAimLHandBlendSpace/blend_position", blend_value)

	# Horizontal mouse — rotate the pivot
	camera_pivot.rotate_y(-mouse_delta.x)
	
	# calclulate invert factor
	var invert_factor = 1.0
	if invert_y:
		invert_factor = -1.0

	# Vertical mouse - move the camera up and down
	camera.position.y = clamp(
		camera.position.y - mouse_delta.y * invert_factor,
		-1.0,
		9.0
	)
	
	# force the camera to look at a place near the player
	camera.look_at(camera_pivot.global_position + camera_target_offset)

	mouse_delta = Vector2.ZERO
	
	# draw a sphere where the raycast hits anything
	var hit_position: Vector3
	if raycast.is_colliding():
		hit_position = raycast.get_collision_point()
	else:
		# otherwise pick a point 100m along the raycast
		hit_position = camera.global_position - camera.global_transform.basis.z * 50.0
	# place our mouselook target at that location
	target_node.global_position = hit_position
