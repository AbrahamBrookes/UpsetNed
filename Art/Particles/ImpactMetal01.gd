extends Node3D

@export var particles1: GPUParticles3D
@export var particles2: GPUParticles3D

func play() -> void:
	particles1.emitting = true
	particles1.restart()
	particles2.restart()
