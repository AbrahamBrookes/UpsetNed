extends Node3D

class_name Weapon

## we are using the same object for the world representation of a weapon and the
## logical representation of a weapon. A weapon starts off in the world - dropped
## placed - and can be picked up by player or enemy. When they pick it up the
## player or enemy places the weapon in a WeaponSlot - of which they have one in
## each hand. Then when they fire, we signal the WeaponSlot to fire, which runs
## the fire logic on the Weapon.

# an enum for weapon type so we know if the player can just hold down the trigger
enum WeaponType {
	AUTO,
	SEMI
}

# debug if ya wanna
@export var debug: bool = false

# the projectile scene we will pool and use as bullets
@export var projectile_scene: PackedScene
# the pool of projectiles
var projectile_pool: Array[Node3D] = []

# optional parent node to hold pooled projectiles in world space
@export var projectile_parent: Node3D

# how many rounds in a mag
@export var rounds_per_mag: int = 12
# how many rounds left
@export var rounds_left: int = 12

# accuracy deviation
@export var accuracy_deviation: float = 0.1

# timeout between shots in seconds
@export var fire_timeout: float = 0.25

# where the projectile should fire from
@export var muzzle: Node3D

# how much base damage does the projectile do?
@export var base_damage: float = 100.00

# maximum travel distance for a projectile when no collision is detected
@export var max_range: float = 50.0

# optional collision mask for projectile ray test (defaults to all layers)
@export_flags_3d_physics var projectile_collision_mask: int = 0xFFFFFFFF

# on ready, depending on how many rounds per mag, instantiate that many projectiles
func _ready():
	var pool_parent: Node = projectile_parent if projectile_parent else self
	for i in rounds_per_mag:
		var projectile_instance = projectile_scene.instantiate()
		projectile_instance.visible = false
		if projectile_instance is Node3D:
			projectile_instance.top_level = true
		pool_parent.add_child(projectile_instance)
		projectile_pool.append(projectile_instance)

# fire the weapon
func fire(target_position: Vector3) -> bool:
	#if rounds_left <= 0:
		#return dry_fire()
	#rounds_left -= 1

	# add 0.5 on the y axis to aim at center of mass
	target_position.y += 0.5

	# add a bit of randomness to simulate inaccuracy
	target_position.x += randf_range(-accuracy_deviation, accuracy_deviation)
	target_position.y += randf_range(-accuracy_deviation, accuracy_deviation)
	target_position.z += randf_range(-accuracy_deviation, accuracy_deviation)

	# find the first inactive projectile in the pool
	for projectile in projectile_pool:
		if not projectile.visible:
			# activate and fire the projectile
			projectile.visible = true
			var muzzle_position = muzzle.global_transform.origin
			projectile.global_position = muzzle_position
			var direction = target_position - muzzle_position
			if direction.length_squared() == 0.0:
				direction = -muzzle.global_transform.basis.z
			var direction_normalized = direction.normalized()

			var ray_end = muzzle_position + direction_normalized * max_range
			var final_position = ray_end
			var space_state = get_world_3d().direct_space_state if is_inside_tree() else null
			if space_state:
				var query = PhysicsRayQueryParameters3D.create(muzzle_position, ray_end)
				query.collision_mask = projectile_collision_mask
				query.exclude = [self, projectile]
				var hit = space_state.intersect_ray(query)
				if not hit.is_empty():
					final_position = hit.position

			projectile.look_at(final_position)

			var distance = muzzle_position.distance_to(final_position)
			var speed = 50.0  # units per second
			var travel_time = distance / speed
			var tween = create_tween()
			tween.tween_property(
				projectile,
				"global_position",
				final_position,
				travel_time
			)
			tween.tween_callback(Callable(self, "_release_projectile").bind(projectile))

			if debug: 
				DebugDraw3D.draw_line(
					muzzle_position,
					final_position,
					Color.RED,
					1.0
				)
			break
	
	return true

func _release_projectile(projectile: Node3D) -> void:
	print('releasing projectile')
	projectile.visible = false
	projectile.global_position = Vector3.ZERO

# when we are out of ammo
func dry_fire() -> bool:
	print("click!")
	return false
