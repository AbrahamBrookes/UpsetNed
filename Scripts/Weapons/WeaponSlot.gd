extends Node3D

class_name WeaponSlot

## A Weapon Slot is a component on an enemy that may hold a weapon.
## We reference the weaponw hen shooting, but the WeaponSlot allows
## the NPC to drop a   nd pick up weapons

# the weapon currently in this weapon slot
@export var weapon: Weapon

# fire the weapon
func fire(target: Vector3) -> bool:
	
	# if we don't have a weapon, we can't fire
	if not weapon:
		return false
	
	# if the weapon can't be fired, wth man?
	if not "fire" in weapon:
		print("No fire method in currently equipped weapon", weapon.name)
		return false
	
	# otherwise fire - this might return false if firing fails (no ammo)
	return weapon.fire(target)
