## Parent class for attribute sets. Contains relevant signals, methods
class_name AttributeSetBase extends Resource

signal attribute_changed(attribute : AttributeBase, old_value : float, new_value : float)

var attributes : Dictionary[AttributeBase, float]

func change_attribute(type : AttributeBase, new_value : float):
	# do checks, etc
	attributes.set(type, new_value)
	
