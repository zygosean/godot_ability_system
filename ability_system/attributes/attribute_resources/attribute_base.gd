## Base class to generate attributes
class_name AttributeBase extends Resource

@export var attribute : StringName
@export var value : float
@export var max_value : float

func set_value(new_value : float):
	if new_value > max_value : 
		value = max_value
		return
	value = new_value
