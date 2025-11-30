class_name FreeMoveState extends State

func enter(owner : CharacterBase, msg := {}):
	# Set animation blend flags here if needed
	owner.clear_horizontal_velocity()
	owner.disable_gravity()
	
func exit(owner : CharacterBase, msg := {}):
	pass
	
func handle_input(owner : CharacterBase, input : Dictionary):
	pass

func physics_step(owner : CharacterBase, delta : float):
	pass
