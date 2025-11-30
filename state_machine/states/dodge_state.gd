class_name DodgeState extends State

@export var dodge_speed : float = 25.0
@export var dodge_time : float = 0.25

var time_left := 0.0
var dodge_dir : Vector3 = Vector3.ZERO

func enter(owner : CharacterBase, msg := {}):
	# Set animation blend flags here if needed
	owner.velocity = Vector3.ZERO
	if not msg.has("direction"): return
	
	dodge_dir = msg.get("direction")
	
func exit(owner : CharacterBase, msg := {}):
	pass
	
func handle_input(owner : CharacterBase, input : Dictionary):
	pass
	
func physics_step(owner : CharacterBase, delta : float):
	pass
	
