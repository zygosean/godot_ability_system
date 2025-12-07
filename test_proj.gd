extends CharacterBody3D

var hit = false
var time_alive : float = 5.0

@onready var collision_shape := $CollisionShape3D

func _ready():
	pass

func _physics_process(delta : float):
	if hit: return
	time_alive -= delta
	if time_alive < 0:
		hit = true
		explode.rpc()
	var col := move_and_collide(delta * velocity)
	if col:
		var collider = col.get_collider()
		if collider and collider.has_method("hit"):
			collider.hit.rpc()
		collision_shape.disabled = true
		explode.rpc()
		hit = true
		
func explode():
	pass # trigger anim
	
func destroy():
	# check for authority
	queue_free()

	
