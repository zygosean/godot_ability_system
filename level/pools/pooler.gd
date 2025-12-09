class_name Pooler extends Node

var pool : Array[Node3D]
var reserved : Array[Node3D]

func populate_pool(scn :  PackedScene, num : int):
	for i in range(0, num):
		var obj := scn.instantiate()
		obj.visible = false
		obj.set_physics_process(false)
		obj.set_process(false)
		add_child(obj)
		pool.append(obj)
		
func draw_from_pool(global_xform : Transform3D) -> Node3D:
	if pool.is_empty(): return null # or grow pool
	var obj : Node3D = pool.pop_back()
	obj.global_transform = global_xform
	obj.visible = true
	obj.set_physics_process(true)
	obj.set_process(true)
	return obj
	
func return_to_pool(obj : Node3D):
	obj.visible = false
	obj.set_physics_process(false)
	obj.set_process(false)
