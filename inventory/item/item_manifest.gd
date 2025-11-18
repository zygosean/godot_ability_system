class_name ItemManifest extends Resource

#enum FragmentTags{CONSUMABLE, EQUIPMENT, FLAVOUR_TEXT, GRID, HIGHLIGHT, ICON, ITEM_NAME, ITEM_TYPE, PRIMARY_STAT, 
					#REQ_LEVEL, SELL_VALUE, STACKABLE}

@export var item_category : InventoryComponent.ItemCategory
@export var fragments : Array[ParentFragment]
@export var fragment_tags : Array[InventoryGridStatics.FragmentTags]

@export var item_type : StringName

@export var tags : PackedStringArray

func manifest_signals():
	pass
	#for fragment in fragments:
		

func get_fragment_of_type(type_to_find):
	if type_to_find == null: return
	if type_to_find.get_script() == null:
		push_error("ItemManifest - Script not found [func get_fragment_of_type] in object: ", type_to_find.get_global_name())
		return
	for fragment in fragments:
		if fragment.get_script() == type_to_find.get_script():
			return fragment
	return null
	
func get_fragment_by_enum_tag(tag : InventoryGridStatics.FragmentTags) -> ParentFragment:
	match tag:
		InventoryGridStatics.FragmentTags.CONSUMABLE:
			return _get_fragment_by_tag("FragmentTags.ConsumableFragment")
		InventoryGridStatics.FragmentTags.EQUIPMENT:
			return _get_fragment_by_tag("FragmentTags.EquipmentFragment")
		InventoryGridStatics.FragmentTags.FLAVOUR_TEXT:
			return _get_fragment_by_tag("FragmentTags.FlavourTextFragment")
		InventoryGridStatics.FragmentTags.GRID:
			return _get_fragment_by_tag("FragmentTags.GridFragment")
		InventoryGridStatics.FragmentTags.HIGHLIGHT:
			return _get_fragment_by_tag("FragmentTags.HighlightFragment")
		InventoryGridStatics.FragmentTags.ICON:
			return _get_fragment_by_tag("FragmentTags.IconFragment")
		InventoryGridStatics.FragmentTags.ITEM_NAME:
			return _get_fragment_by_tag("FragmentTags.ItemNameFragment")
		InventoryGridStatics.FragmentTags.ITEM_TYPE:
			return _get_fragment_by_tag("FragmentTags.ItemTypeFragment")
		InventoryGridStatics.FragmentTags.PRIMARY_STAT:
			return _get_fragment_by_tag("FragmentTags.PrimaryStatFragment")
		InventoryGridStatics.FragmentTags.REQ_LEVEL:
			return _get_fragment_by_tag("FragmentTags.RequiredLevelFragment")
		InventoryGridStatics.FragmentTags.SELL_VALUE:
			return _get_fragment_by_tag("FragmentTags.SellValueFragment")
		InventoryGridStatics.FragmentTags.STACKABLE:
			return _get_fragment_by_tag("FragmentTags.StackableFragment")
	return null
	
func _get_fragment_by_tag(gameplay_tag : StringName) -> ParentFragment:
	for fragment in fragments:
		if fragment.tag == gameplay_tag:
			return fragment
	return null
	
func get_frag_by_enum(e : InventoryGridStatics.FragmentTags):
	for fragment in fragments:
		if fragment.fragment_tag == e:
			return fragment
	return null
	
func manifest() -> InventoryItem: # Take in 'outer' ?
	var item : InventoryItem = InventoryItem.new()
	item.item_manifest = self
	for fragment in item.item_manifest.fragments:
		fragment.manifest()
		tags.append(fragment.tag)
	# clear_fragments() ?
	return item
	
#func manifest_fragments() -> Array[ParentFragment]:
	#var fragment_array : Array[ParentFragment]
	#for fragment in fragments:
		#var unique_frag = fragment.get_script().new()
		##TODO: Set values on unique frag
		#fragment_array.append(unique_frag)
	#return fragment_array
		
		
	
