extends CharacterBody3D

func _physics_process(delta : float):
	move_and_collide(delta * velocity)
	
