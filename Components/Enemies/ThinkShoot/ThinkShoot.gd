extends Node

class_name ThinkShoot

## this component handles enemies shooting. This is based on clickshoot
## but there is no human clicking, so the shooting needs to be handled
## by the cpu

# timers for holding the gun in position for a sec after shooting
@onready var l_hold_timer: Timer = $l_hold_timer
@onready var r_hold_timer: Timer = $r_hold_timer

## The cooldown timer for the left hand shooting
@export var l_cooldown_timer: Timer
## The cooldown timer for the right hand shooting
@export var r_cooldown_timer: Timer

# state bools for if the arms are extended
var r_shooting: bool = false
var l_shooting: bool = false

# states will have to toggle us between standing and sliding modes
var sliding: bool = false

# the anim tree for looking
@export var anim_tree: AnimationTree

# a reference to the left and right weapons
@export var l_weapon_slot: WeaponSlot
@export var r_weapon_slot: WeaponSlot

# a reference to the blackboard so we can grab out the current_target
@export var blackboard: BehaviourTreeBlackboard

func _ready():
	# start the r timer cooldown with a small offset so they are not in sync
	l_cooldown_timer.start(0.2)
	r_cooldown_timer.start(0.4)


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


func _fire_r(target: Vector3):
	r_shooting = true
	r_hold_timer.start()
	r_weapon_slot.fire(target)
	r_cooldown_timer.start()


func _fire_l(target: Vector3):
	l_shooting = true
	l_hold_timer.start()
	l_weapon_slot.fire(target)
	l_cooldown_timer.start()


func _on_r_timer_timeout():
	r_shooting = false


func _on_l_timer_timeout():
	l_shooting = false


func _on_signal_fire_left_action_emit() -> void:
	var target: Node3D = blackboard.get_blackboard_value("current_target")
	_fire_l(target.global_position)


func _on_signal_fire_right_action_emit() -> void:
	var target: Node3D = blackboard.get_blackboard_value("current_target")
	_fire_r(target.global_position)
