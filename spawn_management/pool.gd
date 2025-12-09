class_name Pool extends Resource

@export var type : PackedScene
@export var num_to_pool : int

var pool : Array[Node3D]
var num_available : int

func _init():
	for i in range(0, num_to_pool):
		if not type.can_instantiate(): return
		store()
	num_available = num_to_pool
		
func spawn():
	if num_available < pool.size()
	
func store():
	var obj = type.instantiate()
	obj.visible = false
	obj.set_process(false)
	obj.set_physics_process(false)
	pool.append(obj)
	
func _grow_pool(): # likely need to batch this operation
	var new_size : int = pool.size() * 2
	for i in range(num_available, new_size):
		store()
	num_available = new_size
