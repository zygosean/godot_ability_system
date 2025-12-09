# Instead of an autoload, couldn't this just be a node in the level?

extends Node

func spawn_projectile(position : Vector3, direction : Vector3, params : ProjectileEffectParams) -> CharacterBody3D:
	var p := params.projectile.instantiate()
	p.global_transform.origin = position
	p.velocity = direction.normalized() * params.initial_speed
	get_tree().current_scene.add_child(p)
	return p

func spawn_debug_mesh(position : Vector3, params : DebugMeshParams) -> CharacterBody3D:
	var mesh := params.debug_mesh.instantiate()
	mesh.global_transform.origin = position
	get_tree().current_scene.add_child(mesh)
	return mesh
