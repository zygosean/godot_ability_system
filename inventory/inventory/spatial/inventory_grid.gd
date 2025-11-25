## Controls logic of an inventory grid
class_name InventoryGrid extends Control

signal hover_item_created(HoverItem)
signal grid_size_completed(Vector2i)

@export var tile_size : float = 40 # Where can I set this better?
@export var slotted_items : Dictionary[int, SlottedItem]
@export var total_margins : int = 15 # Temporary -> margins hard coded in inspector
@export var tab_height : int = 25 # Temporary -> hard coded here

var item_category : GridTypes.ItemCategory = GridTypes.ItemCategory.NONE
var grid_slots : Array[GridSlot]

var rows : int = 8
var columns : int = 16

var hover_item : HoverItem

@onready var hover_item_scene := preload("res://inventory/inventory/widgets/hover_item/hover_item.tscn")
@onready var slotted_item_scene := preload("res://inventory/inventory/widgets/slotted_items/slotted_item.tscn")
@onready var grid_slot_scene := preload("res://inventory/inventory/grid_slots/grid_slot.tscn")

func _ready():
	pass

func construct_grid():
	var new_size : Vector2i = Vector2i(columns * tile_size + total_margins, rows * tile_size + total_margins + tab_height)
	self.set_size(new_size)
	emit_signal("grid_size_completed", new_size)
	for j in range(0, rows):
		for i in range(0, columns):
			var grid_slot = grid_slot_scene.instantiate()
			add_child(grid_slot)
			var pos : Vector2i = Vector2i(i, j)
			grid_slot.tile_index = InventoryStatics.get_index_from_pos(pos, columns)
			grid_slot.set_position(pos * grid_slot.get_texture_size())
			grid_slots.append(grid_slot)


	
			
func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pass
		#print(self.name)

## Generate a SlotAvailabilityResult via the manifest. 
func has_room_for_item(manifest : ItemManifest, stack_amount_override : int = -1) -> SlotAvailabilityResult:
	var result = SlotAvailabilityResult.new()
	
	var stackable_fragment : ItemStackableFragment = ItemStackableFragment.new()
	stackable_fragment = manifest.get_fragment_by_enum_tag(InventoryGridStatics.FragmentTags.STACKABLE)
	
	result.is_stackable = true if stackable_fragment != null else false
	
	var max_stack_size : int = stackable_fragment.max_stack_size if stackable_fragment != null else 1
	var amount_to_fill : int = stackable_fragment.stack_count if stackable_fragment != null else 1
	if stack_amount_override != -1 and result.is_stackable:
		amount_to_fill = stack_amount_override
	
	var checked_indices : Dictionary[int, bool]
	for grid_slot in grid_slots:
		#print("inv grid - grid_slot checked: ", grid_slot.tile_index)
		if amount_to_fill == 0: break
		
		if InventoryGridStatics.is_index_claimed(checked_indices, grid_slot.tile_index): continue
		if not is_in_grid_bounds(grid_slot.tile_index, get_item_dimensions(manifest)): continue
		
		var tentatively_claimed : Dictionary[int, bool] = InventoryGridStatics.has_room_at_index(grid_slot, 
																								grid_slots, 
																								columns, 
																								get_item_dimensions(manifest), 
																								checked_indices, 
																								manifest.item_category, 
																								max_stack_size)
		
		if not grid_slot.is_available and not result.is_stackable: continue
			
		var amount_to_fill_in_slot : int = InventoryGridStatics.determine_amount_to_fill_for_slot(result.is_stackable, 
																								max_stack_size, 
																								amount_to_fill, 
																								grid_slot, 
																								grid_slots)
		if amount_to_fill_in_slot == 0 : continue
		
		checked_indices.merge(tentatively_claimed)
		
		result.total_room_to_fill += amount_to_fill_in_slot
		
		var new_slot_availability = SlotAvailability.new()
		new_slot_availability.populate_availability(grid_slot, result)
		
		result.slot_availabilities.append(new_slot_availability)
		
		amount_to_fill -= amount_to_fill_in_slot
		result.remainder = amount_to_fill
		if amount_to_fill == 0 : return result
	return result


func is_in_grid_bounds(index : int, dimensions : Vector2i) -> bool:
	if index < 0 or index >= grid_slots.size(): return false
	var end_column : int = (index % columns) + dimensions.x
	var end_row : int = (index / columns) + dimensions.y
	
	return end_column <= columns && end_row <= rows
	
func get_item_dimensions(manifest : ItemManifest) -> Vector2i:
	var grid_frag : ItemGridFragment
	grid_frag = manifest.get_fragment_by_enum_tag(InventoryGridStatics.FragmentTags.GRID)
	return grid_frag.grid_size if grid_frag != null else Vector2i(1,1)

func add_item(item : InventoryItem):
	if not matches_category(item): return
	var result : SlotAvailabilityResult = has_room_for_item(item.item_manifest)
	add_item_to_indices(result, item)
	
func matches_category(item : InventoryItem) -> bool:
	return item.item_manifest.item_category == item_category
	
func add_item_to_indices(result : SlotAvailabilityResult, item : InventoryItem):
	for availability in result.slot_availabilities:
		add_item_at_index(item, availability.index, result.is_stackable, availability.amount_to_fill)
		update_grid_slots(item, availability.index, result.is_stackable, availability.amount_to_fill)
	# 1. Get grid fragment, get image fragment, create 'widget', store 'widget' in array/container
	
func add_item_at_index(item : InventoryItem, index : int, stackable : bool, stack_amount : int):
	
	var grid_frag : ItemGridFragment = item.item_manifest.get_frag_by_enum(InventoryGridStatics.FragmentTags.GRID)
	
	var image_frag : ItemIconFragment
	image_frag = item.item_manifest.get_frag_by_enum(InventoryGridStatics.FragmentTags.ICON)

	if not image_frag and not grid_frag: return
	
	var slotted_item : SlottedItem = create_slotted_item(item, stackable, stack_amount, grid_frag, image_frag, index)
	slotted_items.get_or_add(index, slotted_item)
	add_slotted_item_to_canvas(index, grid_frag, slotted_item)
	#print("inv grid - item added at index: ",index)

func update_grid_slots(item : InventoryItem, index : int, is_stackable_item : bool, stack_amount : int):
	if grid_slots.size() < index: return
	if is_stackable_item:
		grid_slots[index].stack_count = stack_amount
	
	var grid_frag : ItemGridFragment = item.item_manifest.get_frag_by_enum(InventoryGridStatics.FragmentTags.GRID)
	if grid_frag is not ItemGridFragment:
		print("Can't find grid fragment")
		return
	var dimensions : Vector2i = grid_frag.grid_size # Ternary here?
	
	InventoryStatics.for_each_2d(grid_slots, index, dimensions, columns, 
	func(grid_slot: GridSlot): 
		grid_slot.item = weakref(item)
		grid_slot.upper_left_index = index
		grid_slot.set_occupied_texture()
		grid_slot.is_available = false
		#print("GridSlot index updated: ", grid_slot.tile_index)
		)

func add_slotted_item_to_canvas(index : int, grid_frag : ItemGridFragment, slotted_item : SlottedItem):
	add_child(slotted_item)
	slotted_item.set_stack_amount(slotted_item.stack_amount)
	slotted_item.set_image_texture(slotted_item.image_texture)
	slotted_item.size = get_draw_size(grid_frag)
	print ("slotted item size:",slotted_item.size)
	var draw_pos : Vector2 = InventoryStatics.get_pos_from_index(index, columns) * tile_size
	var draw_pos_w_padding : Vector2 = draw_pos + Vector2(grid_frag.grid_padding, grid_frag.grid_padding)
	slotted_item.set_position(draw_pos_w_padding)

	
func create_slotted_item(item : InventoryItem, stackable : bool, stack_amount : int, grid_fragment : ItemGridFragment, icon_fragment : ItemIconFragment, index : int) -> SlottedItem:
	var slotted_item = slotted_item_scene.instantiate()
	slotted_item.item = weakref(item)
	slotted_item.is_stackable = stackable
	slotted_item.image_texture = icon_fragment.icon
	slotted_item.stack_amount = stack_amount
	slotted_item.grid_index = index
	slotted_item.grid_dimensions = grid_fragment.grid_size
	slotted_item.slotted_item_clicked.connect(on_slotted_item_clicked)
	return slotted_item
	
func get_draw_size(grid_frag : ItemGridFragment) -> Vector2:
	var icon_tile_width : float =  tile_size - grid_frag.grid_padding * 2
	return grid_frag.grid_size * icon_tile_width
	
func on_slotted_item_clicked(index : int):
	if grid_slots.size() < index: return
	var item : WeakRef = grid_slots.get(index).item
	
	if not is_instance_valid(hover_item):
		pick_up(item.get_ref(), index)

# ******** HoverItem

func pick_up(clicked_item : InventoryItem, grid_index : int):
	assign_hover_item(clicked_item, grid_index, grid_index) # why need both grid_index?
	remove_item_from_grid(clicked_item, grid_index)
	
## Creates a hover item and sets the mouse_filter to stop for inventory grid
func assign_hover_item(item : InventoryItem, index : int, previous_index : int):
	create_hover_item(item)
	
	hover_item.previous_grid_index = previous_index
	hover_item.update_stack_count(grid_slots[index].stack_count if item.is_stackable else 0)
	mouse_filter = Control.MOUSE_FILTER_STOP
	
func remove_item_from_grid(item : InventoryItem, index : int):
	var grid_frag = ItemGridFragment.new()
	grid_frag = item.item_manifest.get_fragment_of_type(grid_frag)
	if not is_instance_valid(grid_frag): return
	
	InventoryStatics.for_each_2d(grid_slots, index, grid_frag.grid_size, columns, reset_grid_slot)
	
	if slotted_items.has(index):
		var found_slotted_item : SlottedItem = slotted_items.get(index)
		slotted_items.erase(index)
		found_slotted_item.queue_free()
	
## If there is not an existing hover item, instantiaates one and sets its manifest, fragments, and other variables
func create_hover_item(item : InventoryItem):
	if not is_instance_valid(hover_item):
		
		hover_item = hover_item_scene.instantiate()
		emit_signal("hover_item_created", hover_item)
		
	var grid_frag = ItemGridFragment.new()
	grid_frag = item.item_manifest.get_fragment_of_type(grid_frag)
	var icon_frag = ItemIconFragment.new()
	icon_frag = item.item_manifest.get_fragment_of_type(icon_frag)
	if not grid_frag and not icon_frag: return
	
	hover_item.set_image(icon_frag.icon, get_viewport().get_scaling_3d_scale() * get_draw_size(grid_frag))
	
	var weak_item : WeakRef = weakref(item)
	hover_item.item = weak_item
	hover_item.is_stackable = item.is_stackable()
	
	# Need to find solution for "GetOwningPlayer()" ?
	
	#Input.set_custom_mouse_cursor(hover_item.image_texture_rect.texture)

# ******** Hover item end
func reset_grid_slot(grid_slot : GridSlot):
	grid_slot.item = null
	grid_slot.upper_left_index = -1
	grid_slot.set_unoccupied_texture()
	grid_slot.is_available = true
	grid_slot.stack_count = 0
