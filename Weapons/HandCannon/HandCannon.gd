extends Node3D

@export var light: OmniLight3D
@export var particles: GPUParticles3D
@export var projectile_particles: GPUParticles3D
@export var target_node: Node3D

# Flash duration in frames
@export var flash_duration_frames: int = 3
var flash_frames_remaining: int = 0

func _ready():
	if light:
		light.visible = false

func _process(_delta):
	if flash_frames_remaining > 0:
		flash_frames_remaining -= 1
		if flash_frames_remaining <= 0:
			end_flash()

func fire():
	start_flash()
	if particles:
		particles.restart()
	if projectile_particles and target_node:
		# point the projectile particles at the target_node global position
		projectile_particles.look_at(target_node.global_transform.origin)
		projectile_particles.restart()

func start_flash():
	flash_frames_remaining = flash_duration_frames
	
	if light:
		light.visible = true

func end_flash():
	if light:
		light.visible = false
	
