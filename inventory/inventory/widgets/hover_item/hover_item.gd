## Attaches to the cursor on pick/up in inventory 
class_name HoverItem extends MarginContainer

var item : WeakRef = weakref(InventoryItem)
var is_stackable : bool
var stack_amount : int
var previous_grid_index : int

@onready var image_texture_rect := $Image_TextureRect
@onready var stack_count := $StackCount

func set_image(texture : Texture2D, size : Vector2):
	var image = texture.get_image()
	image.resize(size.x, size.y)
	image_texture_rect.texture = ImageTexture.create_from_image(image)

func update_stack_count(count : int):
	stack_amount = count
	
	if count > 0:
		stack_count.show()
		stack_count.text = str(stack_amount)
		# set text (bottom corner)
		# set text visibility
	else:
		stack_count.hide()
		# set text visibility to hidden

func get_item_type() -> StringName:
	if not is_instance_valid(item): return StringName()
	return item.item_manifest.item_type
	
func set_is_stackable(stacks : bool):
	is_stackable = stacks
	if not stacks:
		pass
