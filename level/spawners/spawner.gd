## Child of level class
class_name Spawner extends Node

@export var pool : Pooler
@export var node_to_spawn : PackedScene
@export var spawn_location : Vector3

@onready var level = get_parent()

func spawn():
	var obj := node_to_spawn.instantiate()
	obj.position = spawn_location

func find_type_in_pool(node_to_find : Node3D) -> bool:
	
