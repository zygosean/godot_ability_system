extends Node

func spawn_projectile(position : Vector3, direction : Vector3, params : ProjectileEffectParams) -> RigidBody3D:
	var p := params.projectile.instantiate()
	p.global_transform.origin = position
	p.velocity = direction.normalized() * params.initial_speed
	print ("direction", direction)
	print("velocity: ", p.velocity)
	get_tree().current_scene.add_child(p)
	return p
