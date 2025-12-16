extends Node

class_name Director

## the list of enemies we are controlling - some enemies might be idling. We only want to assign
## roles to the ones that are in combat. (Enemies will tell us when they enter combat)
var enemies_under_command = []

## the current pressure value, calculated on a range of criteria and is a topless float.
## a pressure of 1 is considered all hands on deck, but we can overcook the pressure.
@export var pressure: float = 0.0

func _process(_delta):
	# only assign roles every 0.3s
	if Time.get_ticks_msec() % 300 < 16:
		_assign_roles()

func _assign_roles():
	# the enemies maintain their roles within their behaviour tree blackboard which
	# is publically read/writable

	# if we have no enemies, nothing to do
	if enemies_under_command.size() == 0:
		return
	
	# the pressure tells us how many of each role we want
	var desired_role_counts = {
		"strafer": int(pressure * 2),
		"passer": int(pressure * 1.5),
		"disengager": int(pressure * 3),
		"rusher": int(pressure * 1),
		"alarmer": int(pressure * 0.25)
	}

	# count how many of each role we have in play
	var role_counts = {
		"strafer": 0,
		"passer": 0,
		"disengager": 0,
		"rusher": 0,
		"alarmer": 0,
		"none": 0
	}

	for enemy in enemies_under_command:
		var blackboard = enemy.behaviour_tree.blackboard
		var role: String = blackboard.get_blackboard_value("current_role", "none")
		if role in role_counts:
			role_counts[role] += 1
		else:
			role_counts["none"] += 1  # unknown roles count as none

	# now iterate the enemies and assign roles as needed
	for enemy in enemies_under_command:
		var blackboard = enemy.behaviour_tree.blackboard
		var current_role: String = blackboard.get_blackboard_value("current_role", "none")

		# don't interrupt roles
		if current_role != "none":
			continue

		# find a role that is under the desired count
		for role_name in desired_role_counts.keys():
			if role_counts[role_name] < desired_role_counts[role_name]:
				# assign this role
				blackboard.set_blackboard_value("current_role", role_name)
				role_counts[role_name] += 1
				# if they had a previous role, decrement its count
				role_counts[current_role] -= 1
				break
