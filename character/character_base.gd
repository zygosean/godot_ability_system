class_name CharacterBase extends CharacterBody3D

var motion : Vector2 = Vector2.ZERO
var orientation : Transform3D
var gravity : Vector3

@export_subgroup("Movement")
@export var movement_speed : float = 5.0

func _ready():
	orientation = global_transform
	orientation.origin = Vector3.ZERO
	gravity = (ProjectSettings.get_setting("physics/3d/default_gravity") * ProjectSettings.get_setting("physics/3d/default_gravity_vector")) / 2
	print("gravity: ", gravity)
	
# *** Methods that States can use ***
func get_move_input() -> Vector2:
	return motion
	
func get_movement_basis() -> Basis:
	return Basis.IDENTITY
	
func apply_horizontal_velocity(dir : Vector3):
	velocity.x = dir.x * movement_speed
	velocity.z = dir.z * movement_speed

func clear_horizontal_velocity():
	velocity.x = 0
	velocity.z = 0
	
func apply_gravity():
	velocity += gravity

func disable_gravity():
	velocity.y = 0
	
func commit_movement():
	set_velocity(velocity)
	set_up_direction(Vector3.UP)
	move_and_slide()
