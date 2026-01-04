extends Node3D

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
class_name StateMachine

## States calculate input and create a MovementIntent, which they set on the
## StateMachine, which then emits a signal to move the character
signal indend_to_move(intent: MovementIntent)

@export var anim_tree : AnimationTree
# playback is the engine-level animation tree state machine
var playback: AnimationNodeStateMachinePlayback
# the state to start on, set in the editor
@export var initial_state: State
# debug if ya wanna
@export var debug: bool = false

# the actual thing that drives us - the character body that has the
# move_and_slide and is_on_floor etc
@export var locomotor: CharacterBody3D

# aimspaces for arms when shooting is done using the 
# ClickShoot component. States need a reference to it
@export var click_shoot: ClickShoot

var states : Dictionary = {}
var current_state : State
var previous_state : State

# a reference to the InputSynchronizer if we have one (only when this PlayerCharacter
# is being controlled by the local instance)
@export var input: InputSynchronizer

# a divisor value for ticking at less that 60fps if needed
var tick_divisor: int = 1000

func _ready():
	# protect against misconfiguration
	if not anim_tree:
		push_error("StateMachine: AnimationTree not assigned!")
		return
	
	playback = anim_tree.get("parameters/Locomotion/playback")
	
	# gather and bootstrap our child states
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(TransitionTo)
			# child states need a reference to the state machine
			child.state_machine = self

	if debug:
		print("StateMachine: states loaded: ", states.keys())
	
	if initial_state:
		TransitionTo(initial_state.name)
	else:
		push_error("StateMachine: initial_state not assigned!")

func _process(delta):
	# only tick if the current time ms divisored by tick_divisor is zero
	var time_ms = Time.get_ticks_msec()
	if (time_ms % tick_divisor) == 0:
		# if the current state has a child node called BehaviourTree, tick it
		if current_state and current_state.has_node("BehaviourTree"):
			var bt_node = current_state.get_node("BehaviourTree")
			var btResult: BehaviourTreeResult.Status
			if bt_node and bt_node is BehaviourTree:
				btResult = bt_node.tick()

			# if the result of the behaviour tree is not RUNNING that means it has transitioned
			# to another state, so we should not call Update on the current state
			if btResult != BehaviourTreeResult.Status.RUNNING:
				return

	if current_state:
		current_state.Update(delta)

func _physics_process(_delta):
	# we're not running our physics update in lockstep with the client anymore since we are
	# syncing input to the server and allowing the InputSynchronizer to do client-side prediction.
	# so don't run the current states Physics_Update here anymore - it gets run from the InputSynchronizer
	# if current_state:
	# 	current_state.Physics_Update(delta)
	pass

func TransitionTo(new_state_name: String, extra_data = null) -> bool:
		
	var new_state = states.get(new_state_name.to_lower())
	if not new_state:
		push_error("State " + new_state_name + " not found. Available: " + str(states.keys()))
		return false

	# Prevent transitioning to same state unless explicitly allowed
	if current_state == new_state and not new_state.allow_self_transition:
		return false
		
	if debug:
		push_error("Transitioning: ", current_state.name if current_state else StringName("None"), " -> ", new_state_name)
	
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
	for state_name in state_names:
		if current_state.name.to_lower() == state_name.to_lower():
			return true
	return false

# allow callers to get a given state node if they know its name
func get_state(state_name: String) -> State:
	return states.get(state_name.to_lower())

# given a MovementIntent, emit our movement signal
func set_movement_intent(intent: MovementIntent) -> void:
	emit_signal("indend_to_move", intent)

# since we are decoupling input for the sake of network, states should not poll
# input themselves in order to change states. The network needs to be able to
# call into the state machine in order to change states, and so does the client.
# To allow this, the state machine will duck-type check the current state to see
# if the current state is able to transition. States will define their own methods
# that map to actions, and if they don't react to that action they simply don't
# implement a method for it
func dispatch_action(action: String, data = null):
	if current_state.has_method(action):
		current_state.call(action, data)
	else:
		if debug:
			print("Action '%s' ignored by state %s" % [action, current_state.name])
