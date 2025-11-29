class_name FallingState extends State

func enter(owner : CharacterBase, msg := {}):
	# Set animation blend flags here if needed
	pass
	
func exit(owner : CharacterBase, msg := {}):
	pass
	
func handle_input(owner : CharacterBase, input : Dictionary):
	pass
	
func physics_step(owner : CharacterBase, delta : float):
	owner.apply_gravity()
	owner.commit_movement()

	if owner.is_on_floor():
		request_state_change.emit(StateID.LOCOMOTION, {})
		return
