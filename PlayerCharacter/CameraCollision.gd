extends Node3D

class_name CameraCollision

@export var camera: Camera3D
@export var camera_pivot: Node3D

@export var max_distance := 6.0
@export var min_distance := 1.5
@export var collision_margin := 0.3
@export var zoom_speed := 12.0
@export var collision_mask := 1

var current_distance := max_distance

func _physics_process(delta: float) -> void:
	update_camera_distance(delta)

func update_camera_distance(delta: float) -> void:
	var origin: Vector3 = camera_pivot.global_position
	var desired_pos: Vector3 = origin - camera.global_transform.basis.z * max_distance

	var space := get_world_3d().direct_space_state

	var query := PhysicsRayQueryParameters3D.create(origin, desired_pos)
	query.exclude = [camera_pivot]
	query.collision_mask = collision_mask

	var result := space.intersect_ray(query)

	var target_distance := max_distance

	if result:
		var hit_dist := origin.distance_to(result.position)
		target_distance = max(min_distance, hit_dist - collision_margin)

	current_distance = lerp(
		current_distance,
		target_distance,
		zoom_speed * delta
	)

	# Only adjust distance — no rotation, no look_at
	camera.position.z = -current_distance
