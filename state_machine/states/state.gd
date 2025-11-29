class_name State extends Resource

signal request_state_change(next : State, msg)

enum StateID { LOCOMOTION, FALLING, DODGING, CASTING, SENTINAL }

@export var state : StateID

func enter(owner : CharacterBase, msg := {}):
	pass

func exit(owner : CharacterBase):
	pass
	
func physics_step(owner : CharacterBase, delta : float):
	pass
	
func handle_input(owner : CharacterBase, input : Dictionary):
	pass
