class_name Composite extends CompositeBase

@export var composite_children : Array[CompositeBase]

func _ready():
	for child in get_children():
		if child is not CompositeBase: return
		composite_children.append(child)
		collapse()
		
func apply_function(function: Callable):
	for child in composite_children:
		child.apply_function(function)
