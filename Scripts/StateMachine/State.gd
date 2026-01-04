extends Node3D
class_name State

signal Transitioned(new_state_name: String, extra_data)

#some states may want to transition to themselves but usually not
@export var allow_self_transition: bool = false

# playercharacter is the immediate scene root
@onready var player_character = owner

# allow states to declare their own animation name if they wanna
var animation_override: String = ""

# the state machine is always the immediate parent of the state it is managing
var state_machine : StateMachine

func Enter(_extra_data = null):
	pass

func Exit():
	pass

func Update(_delta: float):
	pass

func Physics_Update(_delta: float):
	pass
