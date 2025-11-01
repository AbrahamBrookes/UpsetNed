extends Node3D
class_name StateMachine

## The state machine applies only to the player character. In our game the player
## can be in arange of states, and these states influence things like which animation
## to run, what the controller does and what states can be transitioned to. For instance
## the player can climb a ladder, so the left and right inputs can be ignored, they
## are not able to attack, and they need to use the 'climbing ladder' animation.
## The state machine is driven by State objects which are children of the StateMachine.
## Each State object has its own script which defines what happens when the state is entered,
## exited, and what happens each frame while in that state. States can emit a signal
## to transition to another state, or the StateMachine can be told to transition to
## another state by other objects, such as the player controller script.
## See the StateMachineTest.gd script in test/unit/Scripts/StateMachine

@export var anim_tree : AnimationTree
# playback is the engine-level animation tree state machine
var playback: AnimationNodeStateMachinePlayback
# the state to start on, set in the editor
@export var initial_state: State
# debug if ya wanna
@export var debug_mode: bool = false

# the actual thing that drives us - the character body that has the
# move_and_slide and is_on_floor etc
@export var locomotor: CharacterBody3D

# aimspaces for arms when shooting is done using the 
# ClickShoot component. States need a reference to it
@export var click_shoot: ClickShoot

var states : Dictionary = {}
var current_state : State
var previous_state : State

# a divisor value for ticking at less that 60fps if needed
var tick_divisor: int = 1000

func _ready():
	# protect against misconfiguration
	if not anim_tree:
		push_error("StateMachine: AnimationTree not assigned!")
		return
	
	playback = anim_tree.get("parameters/Locomotion/playback")
	
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(TransitionTo)
			# child states need a reference to the state machine
			child.state_machine = self

	if debug_mode:
		print("StateMachine: states loaded: ", states.keys())
	
	if initial_state:
		TransitionTo(initial_state.name)
	else:
		push_error("StateMachine: initial_state not assigned!")


func _process(delta):
	# only tick if the current time ms divisored by tick_divisor is zero
	var time_ms = Time.get_ticks_msec()
	if (time_ms % tick_divisor) == 0:
		if current_state and current_state.has_method("tick_behaviour_tree"):
			var btResult: BehaviourTreeResult.Status = current_state.tick_behaviour_tree()

			# if the result of the behaviour tree is not RUNNING that means it has transitioned
			# to another state, so we should not call Update on the current state
			if btResult != BehaviourTreeResult.Status.RUNNING:
				return

	if current_state:
		current_state.Update(delta)


func _physics_process(delta):
	if current_state:
		current_state.Physics_Update(delta)


func TransitionTo(new_state_name: String, extra_data = null) -> bool:
		
	var new_state = states.get(new_state_name.to_lower())
	if not new_state:
		push_error("State " + new_state_name + " not found. Available: " + str(states.keys()))
		return false

	# Prevent transitioning to same state unless explicitly allowed
	if current_state == new_state and not new_state.allow_self_transition:
		return false
		
	if debug_mode:
		print("Transitioning: ", current_state.name if current_state else "None", " -> ", new_state_name)
	
	previous_state = current_state
	
	if current_state:
		current_state.Exit()
	
	# allowing states to override the animation played
	if playback:
		if new_state.animation_override != "":
			playback.travel(new_state.animation_override)
		else:
			playback.travel(new_state_name)

	new_state.Enter(extra_data)
	
	current_state = new_state
	return true

# an alias for TransitionTo
func travel(new_state_name, extra_data = null):
	TransitionTo(new_state_name, extra_data)

# allow external scripts to check our current state against a list of states
func is_in_states(state_names: Array[String]) -> bool:
	if not current_state:
		return false
	for name in state_names:
		if current_state.name.to_lower() == name.to_lower():
			return true
	return false

# allow callers to get a given state node if they know its name
func get_state(state_name: String) -> State:
	return states.get(state_name.to_lower())
