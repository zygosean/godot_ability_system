## Item will have an item component attached
# Note: can create @tool scripts to help generate items (YouTube)
class_name Item extends Node3D

## Needs a mesh in the world
@export var mesh_inst : MeshInstance3D

## Needs an ItemComponent to hold the ItemManifest
@onready var item_component := $ItemComponent

## Multiplayer *not set up yet*
@onready var multi_sync := $MultiplayerSynchronizer

## Sets the mesh_inst @export var to the Inspector-assigned $Mesh. 
## Connects to highlight fragment and then initializes fragments
func _ready():
	mesh_inst = $MeshInstance3D
	item_component.assign_mesh_to_highlight_frag.connect(get_mesh_for_highlight)
	item_component.picked_up.connect(_on_picked_up)
	item_component.init_fragments()

func get_mesh_for_highlight(fragment : HighlightFragment):
	fragment.mesh = mesh_inst
	
func _on_picked_up():
	queue_free()
