class_name InventoryComponent extends Node

signal on_item_added(InventoryItem)
signal on_item_removed(Item)

signal on_no_room_in_inventory

signal inv_hover_item_created(HoverItem)

enum ItemCategory { EQUIPPABLE, CONSUMABLE, CRAFTABLE, NONE } 
enum ItemType { CUBE }

@export var inventory_menu : SpatialInventory

var item_target : Item

var inventory_list : Array[InventoryItem] # make fast array?
var owning_object

@onready var inventory_menu_scene := preload("res://inventory/inventory/spatial/spatial_inventory.tscn")

# Toggle inventory function ( show / hide)
#
# NOTE:
# We want to decouple the UI elements (Spatial, Grid, etc) from the component in order to utilize the logic
func _ready():
	pass

func handle_input(input : StringName):
	match input:
		&"inventory_toggle":
			toggle_inventory()
	
func set_inventory_menu():
	inventory_menu = inventory_menu_scene.instantiate()
	add_child(inventory_menu)
	inventory_menu.initialize_grids()
	inventory_menu.parent_inv_component = self
	inventory_menu.hide()
	
func connect_add_item():
	for grid in inventory_menu.grids:
		on_item_added.connect(grid.add_item)
		grid.hover_item_created.connect(on_hover_item_created)

func on_hover_item_created(hover_item : HoverItem):
	emit_signal("inv_hover_item_created", hover_item)

func toggle_inventory():
	if inventory_menu.visible == true:
		inventory_menu.hide()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif inventory_menu.visible == false:
		inventory_menu.show()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func try_add_item(item_component : ItemComponent):
	if inventory_menu.parent_inv_component == null:
		inventory_menu.parent_inv_component = self
		
		
	var result : SlotAvailabilityResult = inventory_menu.has_room_for_item(item_component)
	
	var found_item : InventoryItem = find_first_item_by_type(item_component.item_manifest.item_type)
	result.item = found_item
	
	if is_instance_valid(result.item) and result.is_stackable == true:
		server_add_stacks_to_item(item_component, result.total_room_to_fill, result.remainder)
	
	elif result.total_room_to_fill > 0:
		server_add_new_item(item_component, result.total_room_to_fill if result.is_stackable else 0, result.remainder) # ternary op in godot
		
	#emit_signal("on_no_room_in_inventory")

@rpc()
func server_add_new_item(item_component : ItemComponent, stack_count : int, remainder : int):
	# TODO: Make array class with add_entry
	var inventory_item : InventoryItem = item_component.item_manifest.manifest()
	# 
	inventory_list.append(inventory_item)
	inventory_item.total_stack_count = stack_count
	
	for grid in inventory_menu.grids:
		if inventory_item.item_manifest.item_category == grid.item_category:
			grid.add_item(inventory_item)
	
	var stackable_fragment : ItemStackableFragment
	if inventory_item.item_manifest.get_fragment_of_type(ItemStackableFragment) != null: 
		stackable_fragment.stack_count = remainder
	
	
	# TODO: tell item to destroy itself
	
@rpc()
func server_add_stacks_to_item(item_component : ItemComponent, stack_count : int, remainder : int):
	var item_type : StringName = item_component.item_manifest.item_type
	var item = find_first_item_by_type(item_component.item_manifest.item_type)
	
	if not is_instance_valid(item): return
	
	var stackable_fragment : ItemStackableFragment = item.item_manifest.get_fragment_by_enum_tag(InventoryGridStatics.FragmentTags.STACKABLE)
	if stackable_fragment == null: return
	
	stackable_fragment.set_stack_count(item.total_stack_count + stack_count) 
	
	if remainder == 0:
		item_component.on_picked_up()
	else:
		stackable_fragment.set_stack_count(remainder)
	
# On fast array in CPP
func find_first_item_by_type(item_type_tag : StringName) -> InventoryItem:
	for item in inventory_list:
		if item.item_manifest.item_type == item_type_tag:
			return item
	return null
