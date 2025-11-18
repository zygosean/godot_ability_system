class_name ItemNameFragment extends ParentFragment

@export var item_name : String
@export_multiline var item_description_template : String #use {} to format

var _item_description_formatted : String = ""
var item_description_formatted : String: 
	set(value):
		_item_description_formatted = value
	get:
		return _item_description_formatted
		
func _init():
	fragment_tag = InventoryGridStatics.FragmentTags.ITEM_NAME

func format_description(args: Array):
	item_description_formatted = item_description_template.format(args)
	
