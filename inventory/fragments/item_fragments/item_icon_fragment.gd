class_name ItemIconFragment extends ParentFragment

@export var icon : Texture2D
@export var icon_dimensions : Vector2

func _init():
	fragment_tag = InventoryGridStatics.FragmentTags.ICON
