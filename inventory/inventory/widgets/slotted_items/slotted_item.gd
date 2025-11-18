## Item slotted into an InventoryGrid.
class_name SlottedItem extends MarginContainer

signal slotted_item_clicked(int)

@export var image_texture : Texture2D
@export var stack_amount : int

var grid_index : int
var grid_dimensions : Vector2i
var item : WeakRef = weakref(InventoryItem) # Look into this further
var is_stackable : bool = false

@onready var stack_count := $StackCount
@onready var image_texture_rect := $Image_TextureRect

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	call_deferred("_set_image_texture_rect")
	call_deferred("_set_stack_count")
	if is_stackable:
		var item_get : InventoryItem = item.get_ref()
		if item_get == null: return
		var stackable_frag : ItemStackableFragment = item_get.item_manifest.get_fragment_by_enum_tag(InventoryGridStatics.FragmentTags.STACKABLE)
		stackable_frag.stack_count_changed.connect(set_stack_amount)

	
## Texture from IconFragment passed into set_image
func set_image_texture(texture : Texture2D):
	image_texture = texture

func set_stack_amount(stack_count_in : int):
	stack_amount = stack_count_in
	_set_stack_count()
	
func _set_stack_count():
	if stack_count == null:
		print("Slotted item not ready - stack_count == null")
		return
	
	stack_count.text = str(stack_amount)
	if stack_amount <= 1:
		stack_count.hide()
	elif stack_amount > 1:
		stack_count.show()
	
func _set_image_texture_rect():
	if image_texture_rect == null:
		print("Invalid slotted item.")
		return
	
	var image = image_texture.get_image()
	image_texture_rect.texture = ImageTexture.create_from_image(image)
	stack_count.size = self.size
	print(self.size)
	
	
func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("slotted_item_clicked", grid_index)
		

func _on_mouse_entered():
	pass
