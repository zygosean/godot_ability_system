class_name LeafImage extends Leaf

@export var image_icon : Image
@export var sizebox_icon : Image

@onready var texture_rect := $TextureRect

func set_image():
	texture_rect.texture = image_icon
