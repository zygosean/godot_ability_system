## Individual grid slot added to SpatialInventory's InventoryGrids
class_name GridSlot extends Control

enum GridSlotState{OCCUPIED, UNOCCUPIED, SELECTED, GREYEDOUT}

@export var occupied_texture : Texture2D
@export var unoccupied_texture : Texture2D
@export var selected_texture : Texture2D
@export var greyed_out_texture : Texture2D

var grid_slot_state : GridSlotState
var tile_index : int
var stack_count : int
var upper_left_index : int
#var inventory_item : Item
var is_available : bool = true
var item : WeakRef

@onready var grid_slot_texture := $TextureRect

func _ready():
	if grid_slot_texture == null: return
	grid_slot_texture = TextureRect.new()
	add_child(grid_slot_texture)
	grid_slot_texture.texture = unoccupied_texture

func get_texture_size() -> Vector2i:
	var float_vec = grid_slot_texture.texture.get_size()
	var int_vec = Vector2i(float_vec.x, float_vec.y)
	return int_vec
	
func set_occupied_texture():
	grid_slot_state = GridSlotState.OCCUPIED
	grid_slot_texture.texture = occupied_texture
	
func set_unoccupied_texture():
	grid_slot_state = GridSlotState.UNOCCUPIED
	grid_slot_texture.texture = unoccupied_texture
	
func set_selected_texture():
	grid_slot_state = GridSlotState.SELECTED
	grid_slot_texture.texture = selected_texture
	
func set_greyed_out_texture():
	grid_slot_state = GridSlotState.GREYEDOUT
	grid_slot_texture.texture = greyed_out_texture
	
