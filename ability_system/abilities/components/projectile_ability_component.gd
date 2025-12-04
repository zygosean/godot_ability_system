class_name ProjectileAbilityComponent extends Resource

signal request_spawn_projectile(position : Vector3, direction : Vector3, params : ProjectileEffectParams)

@export var projectile : PackedScene
@export var proj_effect_params : ProjectileEffectParams
var spawn_location : Vector3
var spawn_direction : Vector3

func spawn_projectile(target_location : Vector3, b_override_pitch : bool = false, pitch_override : float = 0.0):
	var transform := Transform3D.IDENTITY
	transform.origin = spawn_location
	transform = transform.looking_at(target_location, Vector3.UP)
	spawn_direction = -transform.basis.z
	
	emit_signal("request_spawn_projectile", spawn_location, spawn_direction, proj_effect_params)
