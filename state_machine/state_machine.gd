class_name StateMachine extends Node

signal state_changed(previous : StringName, next : StringName)

@export var initial_state : State
@export var state_list : Array[State]

var owner_body : CharacterBase
var current_state : State
var states : Dictionary = {}

func _ready():
	owner_body = get_parent() as CharacterBase
	assert(owner_body != null)
	
	for s in state_list:
		states[s.state] = s
		s.request_state_change.connect(request_state_change)
	if initial_state:
		_change_state_internal(initial_state.state, {})

func tick_physics(delta : float):
	if current_state:
		current_state.physics_step(owner_body, delta)

		
func dispatch_input(input : Dictionary):
	if current_state:
		current_state.handle_input(owner_body, input)
		
func request_state_change(next_state_id: State.StateID, msg := {}):
	_change_state_internal(next_state_id, msg)

func _change_state_internal(next_state_id : State.StateID, msg := {}):
	if not states.has(next_state_id):
		return
	var previous_state_id : State.StateID = current_state.state if current_state else State.StateID.SENTINAL
	if current_state:
		current_state.exit(owner_body)
	current_state = states[next_state_id]
	current_state.enter(owner_body, msg)
	state_changed.emit(previous_state_id, current_state.state)
