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

# timeout between shots in seconds
@export var fire_timeout: float = 0.25

# where the projectile should fire from
@export var muzzle: Node3D

# how much base damage does the projectile do?
@export var base_damage: float = 100.00

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

	# find the first inactive projectile in the pool
	for projectile in projectile_pool:
		if not projectile.visible:
			# activate and fire the projectile
			projectile.visible = true
			projectile.global_position = muzzle.global_transform.origin
			projectile.look_at(target_position)
			# tween the projectile forward
			var speed = 50.0  # units per second
			var distance = muzzle.global_transform.origin.distance_to(target_position)
			var travel_time = distance / speed
			var tween = create_tween()
			tween.tween_property(
				projectile,
				"global_position",
				target_position,
				travel_time
			)
			tween.tween_callback(Callable(self, "_release_projectile").bind(projectile))

			if debug: 
				DebugDraw3D.draw_line(
					muzzle.global_transform.origin,
					target_position,
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
