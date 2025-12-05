class_name StateLocomotion extends State

@export var accel_speed : float = 50.0
@export var rotation_speed : float = 10.0

func enter(owner : CharacterBase, msg := {}):
	# Set animation blend flags here if needed
	pass
	
func exit(owner : CharacterBase, msg := {}):
	pass
	
func handle_input(owner : CharacterBase, input : Dictionary):
	pass
	
func rotate_owner(owner : CharacterBase, target : Vector3, delta : float):
	if target.length() > 0.1:
		var q_from: Quaternion = owner.orientation.basis.get_rotation_quaternion()
		var q_to: Quaternion = Transform3D().looking_at(-target, Vector3.UP).basis.get_rotation_quaternion()
		owner.orientation.basis = Basis(q_from.slerp(q_to, delta * rotation_speed))

func physics_step(owner : CharacterBase, delta : float):
	super(owner, delta)
	# These need to be exposed on NPC and player
	var motion : Vector2 = owner.get_move_input()
	var movement_basis : Basis = owner.get_movement_basis()
	
	var movement_z : Vector3 = -movement_basis.z
	var movement_x :Vector3 = -movement_basis.x
	
	movement_z.y = 0.0
	movement_z = movement_z.normalized()
	movement_x.y = 0.0
	movement_x = movement_x.normalized()
	
	var target : Vector3 = movement_x * motion.x + movement_z * motion.y
	
	rotate_owner(owner, target, delta)

# Apply root motion if you want (same as your original; optional).
	#var root_motion := Transform3D(owner.anim_tree.get_root_motion_rotation(), owner.anim_tree.get_root_motion_position())
	#owner.orientation *= root_motion

	# Horizontal velocity in movement direction.
	if target.length() > 0.1:
		target.y = 0.0
		target = target.normalized()
		owner.apply_horizontal_velocity(target)
	else:
		owner.clear_horizontal_velocity()
		
	# Ground/air handling, similar to Unreal switching to Falling when not walking. [web:13]
	if not owner.is_on_floor():
		owner.apply_gravity()
		request_state_change.emit(StateID.FALLING, {})
		return
		
	# Move the body.
	owner.commit_movement()
	
	# Apply orientation to visual model.
	owner.orientation.origin = Vector3()
	owner.orientation = owner.orientation.orthonormalized()
	owner.player_model.global_transform.basis = owner.orientation.basis
#
	## Animation flags like your animate() function can be called here or from a separate AnimState.
	#pawn.anim_tree.set("parameters/IdleWalkRun/conditions/move", owner.is_on_floor() and owner.velocity.length() > 0.0)
	#pawn.anim_tree.set("parameters/IdleWalkRun/conditions/idle", owner.is_on_floor() and owner.velocity.length() < 0.5)
	#pawn.anim_tree.set("parameters/conditions/jump", not owner.is_on_floor())
	#pawn.anim_tree.set("parameters/conditions/landed", owner.is_on_floor())
