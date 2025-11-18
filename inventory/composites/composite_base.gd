class_name CompositeBase extends Control

@export var fragment_tag : StringName # look into exporting TagDictionary to a resource

func apply_function(function : Callable):
	pass

func collapse():
	hide()
	
func expand():
	show()
