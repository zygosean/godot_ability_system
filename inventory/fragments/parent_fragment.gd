class_name ParentFragment extends Resource

# if I want a type variable uneditable in child inspector:
# @export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_READ_ONLY) var ...

#NOTE: Types of different fragments in C++ example: ItemFragment(base) -> Grid, InventoryItem, Stackable
	# InventoryItemFragment -> Image(Icon), Text, LabeledNumber, Consumable, Equipment
	# LabeledNumberFragment -> EquipModifier, ConsumeModifer
	# ConsumeModiferFragment -> Health, Mana, ...
	# EquipModiferFragment -> Strength, ... ,
	
#NOTE: Assimilate for Widgets (Expand Composites)
@export var fragment_tag : InventoryGridStatics.FragmentTags

var owner = null
var tag : StringName 
#var tag_dictionary : TagDictionary = load("res://tag_dictionary/tag_dictionary.tres")


func has_mesh_instance() -> bool:
	if not self.owner:
		return false
	for child in self.owner.get_children():
		if child is MeshInstance3D:
			return true
	return false
	
func assimilate():
	pass

func get_fragment_type()->Script:
	return self.get_script()

func manifest():
	pass

func set_fragment_tag(fragment_tag : StringName):
	tag = fragment_tag
