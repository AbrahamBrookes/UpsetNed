extends State

## Idle means just standing there not moving. When the boared timer depletes
## we might try to do something like patrol

@export var bored_timer: Timer

func _ready() -> void:
	# we want to use the Locomote animation state
	animation_override = "Locomote"
	
	bored_timer.timeout.connect(_on_bored_timer_timeout)

func Enter(_extra_data = null):
	# zero out the blend on locomote to get the idle animation
	state_machine.anim_tree.set("parameters/Locomotion/Locomote/blend_position", Vector2(0.0, 0.0))
	
	# start the timer
	bored_timer.start()
	
func Exit():
	# kill the timer
	bored_timer.stop()

func _on_bored_timer_timeout():
	# bored_timer.start()
	# select a random location near the enemy to path to
	var random_offset = Vector3(
		randf_range(-10.0, 10.0),
		0.0,
		randf_range(-10.0, 10.0)
	)
	var target_location = state_machine.locomotor.global_position + random_offset
	state_machine.TransitionTo("PathTo", target_location)
