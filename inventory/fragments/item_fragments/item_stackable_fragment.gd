class_name ItemStackableFragment extends ParentFragment

signal stack_count_changed(int)

@export_category("StackableFragment")
@export var max_stack_size : int = 1
@export var stack_count : int = 1

func _init():
	fragment_tag = InventoryGridStatics.FragmentTags.STACKABLE

func set_stack_count(new_count : int):
	stack_count = new_count
	emit_signal("stack_count_changed", stack_count)
	print("Stack count changed to: ", stack_count)
	print(stack_count_changed.get_connections())
