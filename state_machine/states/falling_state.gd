class_name FallingState extends State

func enter(owner : CharacterBase, msg := {}):
	# Set animation blend flags here if needed
	pass
	
func exit(owner : CharacterBase, msg := {}):
	pass
	
func handle_input(owner : CharacterBase, input : Dictionary):
	pass
	
func physics_step(owner : CharacterBase, delta : float):
	var motion : Vector2 = owner.get_move_input()
	var basis : Basis = owner.get_movement_basis()
	
	var movement_z : Vector3 = -basis.z
	var movement_x :Vector3 = -basis.x
	
	movement_z.y = 0.0
	movement_z = movement_z.normalized()
	movement_x.y = 0.0
	movement_x = movement_x.normalized()
	
	var target : Vector3 = movement_x * motion.x + movement_z * motion.y
	
	if target.length() > 0.1:
		var q_from: Quaternion = owner.orientation.basis.get_rotation_quaternion()
		var q_to: Quaternion = Transform3D().looking_at(-target, Vector3.UP).basis.get_rotation_quaternion()
	
		# Horizontal velocity in movement direction.
	if target.length() > 0.1:
		target = target.normalized()
		owner.apply_horizontal_velocity(target * 0.75)
	else:
		owner.clear_horizontal_velocity()
		
	owner.apply_gravity()
	owner.commit_movement()

	if owner.is_on_floor():
		request_state_change.emit(StateID.LOCOMOTION, {})
		return
