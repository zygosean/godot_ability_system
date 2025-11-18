## Contains information for spatial inventory grid sizing

class_name ItemGridFragment extends ParentFragment

@export_category("Item")
## Int vector, number of spatial grid locations the item occupies
@export var grid_size : Vector2i = Vector2i(1,1)
## Padding to surround icon
@export var grid_padding : float = 0.0

func assimilate():
	fragment_tag = InventoryGridStatics.FragmentTags.GRID
	print(fragment_tag)
