extends Camera3D

## The PlayerCamera handles things like preventing the camera from clipping
## into walls and reacting to when the player is not visible
class_name PlayerCamera

@export var camera_distance := 6.0
@export var min_distance := 1.5
@export var collision_margin := 0.3
@export var zoom_speed := 10.0

@export var collision_mask := 1  # world geometry layer

## The player character
@export var player_character: DeterministicPlayerCharacter

var current_distance := camera_distance

func _physics_process(delta):
	update_camera(delta)

func update_camera(delta):
	var origin := player_character.global_transform.origin

	# Desired camera position (behind the pivot)
	var desired_pos := origin - player_character.global_transform.basis.z * camera_distance

	# Raycast to detect geometry
	var space := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(
		origin,
		desired_pos
	)

	query.exclude = [player_character]
	query.collision_mask = collision_mask

	var result := space.intersect_ray(query)

	var target_distance := camera_distance

	if result:
		var hit_dist := origin.distance_to(result.position)
		target_distance = max(min_distance, hit_dist - collision_margin)

	# Smooth interpolation
	current_distance = lerp(
		current_distance,
		target_distance,
		zoom_speed * delta
	)

	# Apply camera transform
	global_transform.origin = origin - player_character.global_transform.basis.z * current_distance
