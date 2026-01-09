@tool
extends Node3D
class_name TintableProp

@export var albedo_tint: Color = Color.WHITE:
	set(value):
		albedo_tint = value
		apply_tint()

@export var tint_surface_index := 0

@export var mesh: MeshInstance3D

func _ready():
	# if we don't have a mesh, try find a node called Mesh
	if not mesh:
		mesh = $Mesh
		
	apply_tint()

func apply_tint():
	if not is_inside_tree():
		return
	if not mesh:
		return

	var mat := mesh.get_active_material(tint_surface_index)
	if mat == null:
		return

	# Duplicate so each instance is unique
	mat = mat.duplicate()
	mesh.set_surface_override_material(tint_surface_index, mat)

	mat.albedo_color = albedo_tint
