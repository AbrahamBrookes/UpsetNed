extends Node

class_name ClickShoot

## this component handles clicking and shooting. This will be a dual shooter.
## we layer the aiming animation over the rest of the animations so the character
## points in the general direction, like the dive and slide are on a 2d blend space

# timers for holding the gun in position for a sec after shooting
@onready var l_timer: Timer = $l_timer
@onready var r_timer: Timer = $r_timer

# state bools for if the arms are extended
var r_shooting: bool = false
var l_shooting: bool = false

# states will have to toggle us between standing and sliding modes
var sliding: bool = false

# the anim tree for looking
@export var anim_tree: AnimationTree

func _ready():
	pass
	
func _physics_process(_delta: float) -> void:
	# reset all blends
	anim_tree.set("parameters/StandingAimRHandBlend/blend_amount", 0)
	anim_tree.set("parameters/StandingAimLHandBlend/blend_amount", 0)
	anim_tree.set("parameters/SlidingAimLHandBlend/blend_amount", 0)
	anim_tree.set("parameters/SlidingAimRHandBlend/blend_amount", 0)
	print("sliding ", sliding)
	print("r_shooting ", r_shooting)
	print("l_shooting ", l_shooting)
	if r_shooting:
		if sliding:
			anim_tree.set("parameters/SlidingAimRHandBlend/blend_amount", 1)
			print("slide shoot R")
		else:
			anim_tree.set("parameters/StandingAimRHandBlend/blend_amount", 1)
			print("stand shoot R")
	if l_shooting:
		if sliding:
			anim_tree.set("parameters/SlidingAimLHandBlend/blend_amount", 1)
			print("slide shoot L")
		else:
			anim_tree.set("parameters/StandingAimLHandBlend/blend_amount", 1)
			print("stand shoot L")
	

# when the player clicks fire_r or fire_l, toggle the related flag
func _input(event):
	if event.is_action_pressed("fire_r"):
		r_shooting = true
		r_timer.start()
	elif event.is_action_pressed("fire_l"):
		l_shooting = true
		l_timer.start()

func _on_r_timer_timeout():
	r_shooting = false

func _on_l_timer_timeout():
	l_shooting = false
