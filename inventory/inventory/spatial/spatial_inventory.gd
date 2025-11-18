class_name SpatialInventory extends InventoryBase

@export var parent_inv_component : InventoryComponent
@export var grids : Array[InventoryGrid]

# Should these be const? -> would need to be set here then
var grid_equippable : InventoryGrid
var grid_consumable : InventoryGrid
var grid_craftable : InventoryGrid

@onready var inv_grid_scene := preload("res://inventory/inventory/spatial/inventory_grid.tscn")
@onready var inv_tab_container := $Panel/TabContainer

func _ready():
	pass
	#for i in range(0, InventoryComponent.ItemCategory.keys().size() - 1):
		#var inv_grid = inv_grid_scene.instantiate()
		#inv_grid.item_category = InventoryComponent.ItemCategory[InventoryComponent.ItemCategory.keys()[i]]
		#set_grid_types(inv_grid, InventoryComponent.ItemCategory[InventoryComponent.ItemCategory.keys()[i]])
		#inv_tab_container.add_child(inv_grid)
		#inv_grid.construct_grid()
		#inv_tab_container.set_tab_title(i, InventoryComponent.ItemCategory.keys()[i])
		#grids.append(inv_grid)
		#if parent_inv_component != null:
			#parent_inv_component.on_item_added.connect(inv_grid.add_item)
			
func initialize_grids():
	var inv_grid_scene_load : PackedScene = load("res://inventory/inventory/spatial/inventory_grid.tscn")
	for i in range(0, InventoryComponent.ItemCategory.keys().size() - 1):
		var inv_grid = inv_grid_scene_load.instantiate()
		inv_grid.item_category = InventoryComponent.ItemCategory[InventoryComponent.ItemCategory.keys()[i]]
		set_grid_types(inv_grid, InventoryComponent.ItemCategory[InventoryComponent.ItemCategory.keys()[i]])
		inv_tab_container.add_child(inv_grid)
		inv_grid.connect("grid_size_completed", _on_grid_size_completed)
		inv_grid.construct_grid()
		inv_tab_container.set_tab_title(i, InventoryComponent.ItemCategory.keys()[i])
		grids.append(inv_grid)
		if parent_inv_component != null:
			parent_inv_component.on_item_added.connect(inv_grid.add_item)
	
	
func _on_grid_size_completed(new_size : Vector2i):
	set_size(new_size)
	print("new size", new_size)
	
func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pass
		#print(self.name)
		

func has_room_for_item(item_component : ItemComponent) -> SlotAvailabilityResult:
	match (item_component.item_manifest.item_category):
		InventoryComponent.ItemCategory.EQUIPPABLE:
			var result : SlotAvailabilityResult = grid_equippable.has_room_for_item(item_component.item_manifest)
			return result
		InventoryComponent.ItemCategory.CONSUMABLE:
			return grid_consumable.has_room_for_item(item_component.item_manifest)
		InventoryComponent.ItemCategory.CRAFTABLE:
			return grid_craftable.has_room_for_item(item_component.item_manifest)
		_:
			print("Error, no valid item_category on item:")
			return SlotAvailabilityResult.new()

func set_grid_types(grid : InventoryGrid, type : InventoryComponent.ItemCategory):
	match (grid.item_category):
		InventoryComponent.ItemCategory.EQUIPPABLE:
			grid_equippable = grid
		InventoryComponent.ItemCategory.CONSUMABLE:
			grid_consumable = grid
		InventoryComponent.ItemCategory.CRAFTABLE:
			grid_craftable = grid
		_:
			return
			
func has_hover_item() -> bool:
	if is_instance_valid(grid_equippable.hover_item): return true
	if is_instance_valid(grid_consumable.hover_item): return true
	if is_instance_valid(grid_craftable.hover_item): return true
	return false
