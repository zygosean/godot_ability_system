## Attach this to any Node to gove the node Item fragments
class_name ItemComponent extends Node

signal picked_up
signal assign_mesh_to_highlight_frag(HighlightFragment)

signal make_connections

@export var item_manifest : ItemManifest
@export var pickup_message : String

@export var fragments : Array[ParentFragment]


func _ready():
	for fragment in item_manifest.fragments:
		var new_frag = fragment.duplicate(true)
		fragments.append(new_frag)
	item_manifest.item_type = "ItemTypes.Cube"
	
## Must be called by parent after
func init_fragments():
	for fragment in fragments:
		if fragment is HighlightFragment:
			emit_signal("assign_mesh_to_highlight_frag", fragment)
		fragment.assimilate()
	
func manifest():
	pass

func on_picked_up():
	emit_signal("picked_up")
	
