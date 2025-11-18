## Helper functions for InventoryGrid class
class_name InventoryGridStatics extends Object

enum FragmentTags{CONSUMABLE, EQUIPMENT, FLAVOUR_TEXT, GRID, HIGHLIGHT, ICON, ITEM_NAME, ITEM_TYPE, PRIMARY_STAT, 
					REQ_LEVEL, SELL_VALUE, STACKABLE}
					
static func get_fragment_tag(target_manifest : ItemManifest, tag : FragmentTags) -> ParentFragment:
	if not target_manifest.fragment_tags.has(tag): return null
	
	for fragment in target_manifest.fragments:
		if fragment.fragment_tag == tag:
			return fragment
	return null

static func is_index_claimed(indices : Dictionary, index : int):
	return indices.has(index)
	

static func is_upper_left_slot(grid_slot : GridSlot, grid_slot_to_check : GridSlot):
	return grid_slot_to_check.upper_left_index == grid_slot.tile_index
	
	 # need to have an additional loop over the tentatively claimed (instead of using out references)
static func has_room_at_index(grid_slot :GridSlot, 
								grid_slots : Array[GridSlot], 
								columns : int, 
								dimensions : Vector2i, 
								checked_indices : Dictionary,
								item_type : InventoryComponent.ItemCategory, 
								max_stack_size : int
								) -> Dictionary[int, bool]:
	var tentatively_claimed : Dictionary[int, bool]
	InventoryStatics.for_each_2d(grid_slots, grid_slot.tile_index, dimensions, columns, func(sub_grid_slot : GridSlot):
		#print("invStatics.has_room_at_index - sub_grid_slot checked: ", sub_grid_slot.tile_index)
		var slot_constraints : Dictionary[int,bool] = InventoryGridStatics.check_slot_constraints(grid_slot, sub_grid_slot, checked_indices, max_stack_size)
		if slot_constraints.get(sub_grid_slot.tile_index) == false:
			tentatively_claimed.get_or_add(sub_grid_slot.tile_index, true)
		else:
			# Does not have room at index
			tentatively_claimed.get_or_add(sub_grid_slot.tile_index, false)
		)
	return tentatively_claimed
	

# TODO: Check for GameplayTag type
## Returns FALSE for 
static func check_slot_constraints(grid_slot : GridSlot, 
									sub_grid_slot : GridSlot, 
									checked_indices : Dictionary, 
									max_stack_size : int
									) -> Dictionary[int, bool]:
	var out_tentatively_claimed : Dictionary[int, bool]
	if is_index_claimed(checked_indices, sub_grid_slot.tile_index): 
		print("inv_grid_statics - is_index_claimed: ", is_index_claimed(checked_indices, sub_grid_slot.tile_index))
		out_tentatively_claimed.get_or_add(sub_grid_slot.tile_index, false)
		return out_tentatively_claimed
	# Is there a NOT valid item at the index? 
	if not is_instance_valid(sub_grid_slot.item):
		out_tentatively_claimed.get_or_add(sub_grid_slot.tile_index, false)
		return out_tentatively_claimed
	#if not in upper left, return false
	if not is_upper_left_slot(grid_slot, sub_grid_slot):
		out_tentatively_claimed.get_or_add(sub_grid_slot.tile_index, false) 
		return out_tentatively_claimed
	var sub_item : InventoryItem = sub_grid_slot.item.get_ref()
	if sub_item.is_stackable():
		# sub or grid slot
		out_tentatively_claimed.get_or_add(sub_grid_slot.tile_index, false)
		return out_tentatively_claimed
		
	# do the items match?
	#if stackable, are we at max stack size?
	if grid_slot.stack_count >= max_stack_size:
		out_tentatively_claimed.get_or_add(grid_slot.tile_index, true)
		return out_tentatively_claimed
	
	return out_tentatively_claimed

static func determine_amount_to_fill_for_slot(is_stackable : bool, max_stack_size : int, amount_to_fill : int, grid_slot : GridSlot, grid_slots : Array[GridSlot]) -> int:
	var room_in_slot : int = max_stack_size - grid_slots[grid_slot.upper_left_index].stack_count
	
	#var current_slot_stack_count = grid_slot.stack_count
	#if grid_slot.upper_left_index != -1:
		#var upper_left_slot : GridSlot = grid_slots[grid_slot.upper_left_index]
		#current_slot_stack_count = upper_left_slot.stack_count
	#var room_in_slot = max_stack_size - current_slot_stack_count
	#print("Determine amount: room in slot: ", room_in_slot, " | amount to fill: ", amount_to_fill)
	return min(amount_to_fill, room_in_slot) if is_stackable else 1
