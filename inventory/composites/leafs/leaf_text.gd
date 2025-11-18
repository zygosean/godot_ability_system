class_name LeafText extends Leaf

@export var text : String
@export var font_size : int = -1
@export var font : Font

@onready var label := $Label

func _ready():
	if font_size != -1:
		label.add_theme_font_size_override("font_size", font_size)
	if font != null:
		label.add_theme_font_override("font", font)
	if not text.is_empty():
		label.text = text
