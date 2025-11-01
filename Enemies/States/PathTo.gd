extends State

## This state takes a location and uses a NavigationAgent3D to path
## to that location. The way NavigationAgents work is you get them
## to provide a list of locations between you and the target location
## and then you attempt to move the actor towards it. The NavAgent
## also lets you submit your desired velocity and it will compute a
## collision-less velocity for you, so we are using that here via
## the velocity_computed signal

# how fast do we locomote?
@export var move_speed: float = 5.0
# the mesh we will be rotating inside the enemy scene
@export var mesh: Node3D
# the anv agent for accessing the nav mesh
@export var nav_agent: NavigationAgent3D
# the goal location we deciede to move to when we entered this state
var navigation_goal: Vector3

func _ready() -> void:
	# connect the velocity_computed signal from the nav agent
	nav_agent.velocity_computed.connect(_on_velocity_computed)
	
	# we want to use the Locomote animation state
	animation_override = "Locomote"

func _on_velocity_computed(safe_velocity: Vector3):
	state_machine.locomotor.velocity.x = safe_velocity.x
	state_machine.locomotor.velocity.z = safe_velocity.z
	# gravity, jumps, etc.
	if not state_machine.locomotor.is_on_floor():
		state_machine.locomotor.velocity.y -= 30.0 * get_physics_process_delta_time()
	state_machine.locomotor.move_and_slide()

	# get the float speed for animation purposes
	var forward_speed = Vector2(
		state_machine.locomotor.velocity.x,
		state_machine.locomotor.velocity.z
	).length()
	
	# Update animation
	state_machine.anim_tree.set("parameters/Locomotion/Locomote/blend_position", Vector2(0.0, forward_speed))

	# rotate the mesh to face movement direction
	if safe_velocity.length() > 0.1:
		var mesh_rotation = mesh.global_transform.basis.get_euler()
		mesh_rotation.y = atan2(-safe_velocity.x, -safe_velocity.z)
		mesh.rotation = mesh_rotation
	
# when an enemy enters locomote they must pass a destination
func Enter(extra_data = null):
	navigation_goal = extra_data
	# query the nav agent to get a path
	nav_agent.set_target_position(navigation_goal)
	
	# toggle animation blend spaces for in-game pointy arms
	if state_machine.click_shoot:
		state_machine.click_shoot.sliding = false

func Physics_Update(_delta: float):
	# classic Navigation Agent pattern
	if not nav_agent.is_navigation_finished():
		var next = nav_agent.get_next_path_position()
		var desired = (next - state_machine.locomotor.global_position).normalized() * move_speed
		nav_agent.set_velocity(desired)  # preferred velocity -> avoidance solver runs now
	else:
		nav_agent.set_velocity(Vector3.ZERO)
		state_machine.TransitionTo("Idle")
