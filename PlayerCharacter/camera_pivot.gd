extends Node3D

@export var camera: Camera3D
@export var shape_cast: ShapeCast3D

@export var max_distance := 6.0
@export var min_distance := 1.5
@export var collision_margin := 0.15
@export var zoom_speed := 14.0

var current_distance := max_distance

func _physics_process(delta: float) -> void:
	update_camera_distance(delta)

func update_camera_distance(delta: float) -> void:
	# Always align the cast with the pivot's backward direction
	shape_cast.target_position = Vector3(0, 0, -max_distance)
	
	# Save current position
	var original_pos := global_position

	# Lock collision sampling height (shoulder height works well)
	global_position.y = global_position.y * 0.0 + 1.6

	shape_cast.force_shapecast_update()

	# Restore real position
	global_position = original_pos

	var target_distance := max_distance

	if shape_cast.is_colliding():
		var collision_point := shape_cast.get_collision_point(0)
		var hit_dist := global_position.distance_to(collision_point)
		target_distance = max(min_distance, hit_dist - collision_margin)

	current_distance = lerp(
		current_distance,
		target_distance,
		zoom_speed * delta
	)

	# Apply ONLY distance (no rotation, no look_at)
	camera.position.z = -current_distance
