## Representation of the item as manifested in an Inventory
class_name InventoryItem extends Control

@export_category("Inventory")
@export var item_manifest : ItemManifest
@export var total_stack_count : int = 0

func _ready():
	if is_stackable():
		var stackable_frag : ItemStackableFragment
		stackable_frag = item_manifest.get_fragment_by_enum_tag(InventoryGridStatics.FragmentTags.STACKABLE)
		stackable_frag.stack_count_changed.connect(set_stack_count)
		set_stack_count(stackable_frag.stack_count)
		

	
func set_stack_count(count : int):
	total_stack_count = count

func get_fragment_by_type(item : InventoryItem, type_to_find) -> ParentFragment:
	return InventoryStatics.get_type_from_array(item.item_manifest.fragments, type_to_find)
	
func get_fragment_by_tag(item : InventoryItem, type_to_find : StringName) -> ParentFragment:
	if not is_instance_valid(item): return null
	return item.item_manifest.get_fragment_by_tag(type_to_find)
	
func is_stackable() -> bool:
	var stackable_frag : ItemStackableFragment
	stackable_frag = item_manifest.get_fragment_by_enum_tag(InventoryGridStatics.FragmentTags.STACKABLE)
	if stackable_frag != null : return true
	
	return false
