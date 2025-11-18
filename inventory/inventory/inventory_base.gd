class_name InventoryBase extends MarginContainer

signal try_add_item(Item)

var spatial_inv

@onready var spatial_inv_scn := load("res://inventory/spatial/spatial_inventory.tscn")


func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Click")
		
func _on_try_add_item():
	print("try to add item")

func has_room_for_item(item_component : ItemComponent) -> SlotAvailabilityResult:
	return SlotAvailabilityResult.new()
