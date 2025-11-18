class_name Fragments extends Node

signal fragment_list_dispatch

@export_subgroup("Fragments")
@export var _fragments_list : Array[ParentFragment]

func _ready() -> void:
	pass

var fragments_list:
	get: return _fragments_list
	
func get_fragments_list():
	print(typeof(_fragments_list))
	return _fragments_list
	
static func get_fragments_list_by_object(obj : Object):
	pass
	
func get_owner_nodes() -> Array:
	var nodes : Array
	for child in get_owner().get_children():
		nodes.append(child)
	return nodes
