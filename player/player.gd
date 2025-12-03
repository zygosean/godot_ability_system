## Required modules: ability_system, inventory
class_name Player extends CharacterBase

signal highlight
signal unhighlight

enum MoveState { LOCOMOTION, JUMP, DODGE, CASTING, FALLING }

const MOTION_INTERP_SPEED : float = 50.0
const ROTATION_INTERP_SPEED : float = 10.0

const MIN_AIRBORNE_TIME : float  = 0.1

@export_subgroup("Movement")
@export var sprint_multi : float = 1.5
@export var move_state : MoveState

@export_subgroup("AbilitySystem")
@export var ability_actor_info : AbiliyActorInfo

@export_subgroup("Actions")
@export var INTERACT : String = "interact"
@export var DEBUG : String = "debug"
@export var INVENTORY : String = "inventory"

# Advanced Settings
@export_category("Advanced")
@export var UPDATE_ON_PHYSICS := true # Should the update happen on physics ticks?

# Inventory
@export_category("Inventory")
@export var inventory_menu : SpatialInventory

var root_motion : Transform3D

var last_target
var this_target

var input : String
var gravity_test : float = 24.0
var hud : HUD

var gravity_toggle : bool = true

#Debugging in process
var debug_timer_exists : bool = false

var ability_inputs : Array[StringName]
var inventory_inputs : Array[StringName]
var general_inputs : Array[StringName]

@onready var player_input := $InputSynchronizer

@onready var camera_base := $CameraBase
@onready var camera := $CameraBase/CameraRot/SpringArm3D/Camera3D
@onready var mesh_instance := $mannequiny/Skeleton3D/body_001
@onready var ability_system_component := $AbilitySystemComponent
@onready var inventory_component : InventoryComponent = $InventoryComponent
@onready var item_trace := $CameraBase/CameraRot/SpringArm3D/Camera3D/ItemTrace
@onready var player_model := $mannequiny
@onready var state_machine := $StateMachine

@onready var hud_scn := load("res://inventory/UI/HUD/HUD.tscn")

# Animation
var state : MoveState = MoveState.LOCOMOTION
@export var current_anim : MoveState = MoveState.LOCOMOTION
@onready var anim_player : AnimationPlayer = $mannequiny/AnimationPlayer
@onready var anim_tree : AnimationTree = $AnimationTree


func _ready():
	super()
	_populate_input_arrays()
	orientation = player_model.global_transform
	orientation.origin = Vector3()
	
	hud = hud_scn.instantiate()
	add_child(hud)
	
	inventory_component.set_inventory_menu()
	inventory_menu = inventory_component.inventory_menu
	
	ability_system_component.add_startup_abilities()
	
	_connect_signals()
	
func _process(delta: float):
	if !UPDATE_ON_PHYSICS:
		#_handle_move_state_input(delta)
		var input_data := { "motion" : player_input.motion }
		state_machine.dispatch_input(input_data)
		state_machine.tick_physics(delta)
		
	_trace_for_item()
	
	_debug_timer()
	
func _populate_input_arrays():
	for action in InputMap.get_actions():
		if action.begins_with("ability"):
			ability_inputs.append(action)
		if action.begins_with("inventory"):
			inventory_inputs.append(action)
		if action.begins_with("general"):
			general_inputs.append(action)
	
func get_move_input() -> Vector2:
	motion = motion.lerp(player_input.motion, 50.0 * get_physics_process_delta_time())
	return motion
	
func get_movement_basis() -> Basis:
	return player_input.get_camera_rotation_basis()
	
func _physics_process(delta: float) -> void:
	#_handle_move_state_input(delta)
	var input_data := { "motion" : player_input.motion }
	#state_machine.dispatch_input(input_data)
	state_machine.tick_physics(delta)
	
	#_handle_global_input(delta)
	animate("state", delta)
	
func _connect_signals():
	_connect_player_input_signals()
	inventory_component.on_no_room_in_inventory.connect(hud.show_interact_message.bind("NO ROOM IN INVENTORY"))
	inventory_component.connect_add_item()
	inventory_component.inv_hover_item_created.connect(hud.add_hover_item)
	
	ability_system_component.animate_ability.connect(animate_one_shots)
	
func _connect_player_input_signals():
	
	#player_input.ability_input_pressed.connect(ability_system_component.handle_input)
	#player_input.general_input_pressed.connect(_handle_general_input)
	#player_input.inventory_input_pressed.connect(inventory_component.handle_input)
	player_input.input_pressed.connect(parse_input_action)
	
func animate(animation : String, delta:= 0.0):
	anim_tree.set("parameters/IdleWalkRun/conditions/move", is_on_floor() and velocity.length() > 0)
	anim_tree.set("parameters/IdleWalkRun/conditions/idle", is_on_floor() and velocity.length() < 0.5)
	anim_tree.set("parameters/conditions/jump", not is_on_floor())
	anim_tree.set("parameters/conditions/landed", is_on_floor())
	
func change_move_state(state : MoveState):
	move_state = state
	
func animate_one_shots(animation : String, time : float):
	anim_tree.set("parameters/Dodge/dodge/action_speed/scale", time)
	anim_tree.set("parameters/conditions/dodge", animation == "dash")
	
func parse_input_action(action : StringName):
	var component : Node
	if action.begins_with("ability"):
		component = ability_system_component
	if action.begins_with("inventory"):
		component = inventory_component
	if action.begins_with("general"):
		_handle_general_input(action)
	if component == null: return
	component.handle_input(action)

func _handle_general_input(event : StringName):
	match event:
		"general_escape":
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				
		"general_debug":
			pass
				
		"general_interact":
			interact()
	
		
func interact():
	if is_instance_valid(this_target) and InventoryStatics.has_item_component(this_target):
		inventory_component.try_add_item(this_target.item_component)
		this_target.item_component.on_picked_up()

func _trace_for_item():
	var is_targeting_item : bool
	last_target = this_target
	
	if is_instance_valid(item_trace.get_collider()):
		this_target = item_trace.get_collider().get_owner()
	else:
		this_target = null
		
	if this_target == last_target: return
		
	_highlight_item()
				
func _highlight_item():
	if is_instance_valid(this_target) and this_target is Item:
		for fragment in this_target.item_component.fragments:
			if fragment is HighlightFragment:
				fragment.highlight()
				var interact_actions = InputMap.action_get_events("general_interact")
				var interact_button : String = interact_actions[0].as_text().trim_suffix(" (Physical)")
				hud.set_display_message("Press '" + interact_button + "' to pick up Item", true)
				
	if is_instance_valid(last_target) and last_target is Item:
		for fragment in last_target.item_component.fragments:
			if fragment is HighlightFragment:
				fragment.unhighlight()
				hud.hide_message(hud.display_message)

## called in process()
func _debug_timer():
	if debug_timer_exists == false:
		debug_timer_exists = true
		await get_tree().create_timer(1.0).timeout

		#print(velocity)
		debug_timer_exists = false
