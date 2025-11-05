extends Node

class_name ThinkShoot

## this component handles enemies shooting. This is based on clickshoot
## but there is no human clicking, so the shooting needs to be handled
## by the cpu

# timers for holding the gun in position for a sec after shooting
@onready var l_hold_timer: Timer = $l_timer
@onready var r_hold_timer: Timer = $r_timer

# timers for waiting between shots

# state bools for if the arms are extended
var r_shooting: bool = false
var l_shooting: bool = false

# states will have to toggle us between standing and sliding modes
var sliding: bool = false

# the anim tree for looking
@export var anim_tree: AnimationTree

# a reference to the left and right weapons
@export var l_weapon: Node3D
@export var r_weapon: Node3D

func _ready():
	pass
	
func _physics_process(_delta: float) -> void:
	# reset all blends
	anim_tree.set("parameters/StandingAimRHandBlend/blend_amount", 0)
	anim_tree.set("parameters/StandingAimLHandBlend/blend_amount", 0)
	anim_tree.set("parameters/SlidingAimLHandBlend/blend_amount", 0)
	anim_tree.set("parameters/SlidingAimRHandBlend/blend_amount", 0)
	
	if r_shooting:
		if sliding:
			anim_tree.set("parameters/SlidingAimRHandBlend/blend_amount", 1)
			#print("slide shoot R")
		else:
			anim_tree.set("parameters/StandingAimRHandBlend/blend_amount", 1)
			#print("stand shoot R")
	if l_shooting:
		if sliding:
			anim_tree.set("parameters/SlidingAimLHandBlend/blend_amount", 1)
			#print("slide shoot L")
		else:
			anim_tree.set("parameters/StandingAimLHandBlend/blend_amount", 1)
			#print("stand shoot L")
	

# when the player clicks fire_r or fire_l, toggle the related flag
func _input(event):
	if event.is_action_pressed("fire_r"):
		fire_r()
	elif event.is_action_pressed("fire_l"):
		fire_l()
		
func fire_r():
	r_shooting = true
	r_hold_timer.start()
	r_weapon.fire()

func fire_l():
	l_shooting = true
	l_hold_timer.start()
	l_weapon.fire()
	
func _on_r_timer_timeout():
	r_shooting = false

func _on_l_timer_timeout():
	l_shooting = false
