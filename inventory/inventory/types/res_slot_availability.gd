## Used by GridSlot to indicate grid location and availability
class_name SlotAvailability extends Resource

var index : int
var amount_to_fill : int
var is_item_at_index : bool

func _init(in_index = -1, in_amount_to_fill = -1, in_is_item_at_index = false):
	index = in_index
	amount_to_fill = in_amount_to_fill
	is_item_at_index = in_is_item_at_index
	
func populate_availability(slot : GridSlot, result : SlotAvailabilityResult):
	index = slot.upper_left_index if is_instance_valid(result.item) else slot.tile_index
	amount_to_fill = result.total_room_to_fill if result.is_stackable else 0
	is_item_at_index = is_instance_valid(result.item)
