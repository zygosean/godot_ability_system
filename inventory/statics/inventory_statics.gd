## Static function library -- Should this be an autoload?
class_name InventoryStatics extends Node

static func get_index_from_pos(pos : Vector2i, column : int) -> int:
	return pos.x + pos.y * column
	
static func get_pos_from_index(index : int, columns : int) -> Vector2i:
	return Vector2i(index % columns, index / columns)

static func get_item_category_from_item(item : Item) -> InventoryComponent.ItemCategory:
	if is_instance_valid(item):
		return item.item_manifest.item_category
	return InventoryComponent.ItemCategory.NONE

static func get_inventory_comp_from_player(player : Player) -> InventoryComponent:
	if is_instance_valid(player.inventory_component):
		return player.inventory_comopnent
	return null

## 
static func get_fragment_of_type(array : Array, type_to_find):
	for e in array:
		if e is ParentFragment and type_to_find is ParentFragment:
			return e
		if e is ItemGridFragment and type_to_find is ItemGridFragment:
			return e
		if e is ItemIconFragment and type_to_find is ItemIconFragment:
			return e
		if e is ItemNameFragment and type_to_find is ItemNameFragment:
			return e
		if e is HighlightFragment and type_to_find is HighlightFragment:
			return e
	return null
	
	
static func get_type_from_array(array : Array, script_ref):
	for e in array:
		if e.get_script() == script_ref:
			return e
	return null

static func for_each_2d(array, index : int, range_2d : Vector2i, grid_columns : int, function : Callable):
	for j in range_2d.y:
		for i in range_2d.x:
			var coordinates : Vector2i = get_pos_from_index(index, grid_columns) + Vector2i(i, j)
			var tile_index : int = get_index_from_pos(coordinates, grid_columns)
			if tile_index < array.size():
				function.call(array[tile_index])
			
static func try_get_inventory_component(node : Node) -> InventoryComponent:
	var current = node.get_parent()
	while current:
		if current is InventoryComponent: 
			return current
		current = current.get_parent()
	return null
	
static func has_item_component(object : Node) -> bool:
	for child in object.get_children():
		if child is ItemComponent:
			return true
	return false
	
static func debug_print_grid_slot_status(grid : InventoryGrid):
	for slot in grid.grid_slots:
		print("InventoryStatics - pring_grid_slot_status: slot.is_available",slot.is_available)
