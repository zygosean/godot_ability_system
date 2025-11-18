class_name LeafLabeledValue extends Leaf

@export var text_label_font_size : int
@export var value_label_font_size : int

@onready var text_label := $HBoxContainer/TextLabel
@onready var value_label := $HBoxContainer/ValueLabel

func _ready():
	text_label.add_theme_font_size_override("font_size", text_label_font_size)
	value_label.add_theme_font_size_override("font_size", value_label_font_size)
