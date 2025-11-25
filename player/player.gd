## Required modules: ability_system, inventory
class_name Player extends CharacterBody3D

signal highlight
signal unhighlight

enum State { IDLE, RUN, JUMP, DODGE, CASTING, FALLING }

const MOTION_INTERP_SPEED : float = 50.0
const ROTATION_INTERP_SPEED : float = 10.0

@export_subgroup("Movement")
@export var movement_speed : float = 10.0
@export var sprint_multi : float = 1.5

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
var motion : Vector2
var orientation : Transform3D

var last_target
var this_target

var is_dodging : bool = false

var input : String
var gravity_test : float = 24.0
var hud : HUD

var gravity_toggle : bool = true

#Debugging in process
var debug_timer_exists : bool = false

@onready var player_input := $InputSynchronizer

@onready var camera_base := $CameraBase
@onready var camera := $CameraBase/CameraRot/SpringArm3D/Camera3D
@onready var mesh_instance := $mannequiny/Skeleton3D/body_001
@onready var ability_system_component := $AbilitySystemComponent
@onready var inventory_component : InventoryComponent = $InventoryComponent
@onready var item_trace := $CameraBase/CameraRot/SpringArm3D/Camera3D/ItemTrace
@onready var player_model := $mannequiny

@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * ProjectSettings.get_setting("physics/3d/default_gravity_vector")

@onready var hud_scn := load("res://inventory/UI/HUD/HUD.tscn")

# Animation
var state : State = State.RUN
@export var current_anim : State = State.RUN
@onready var anim_player : AnimationPlayer = $mannequiny/AnimationPlayer
@onready var anim_tree : AnimationTree = $AnimationTree


func _ready():
	orientation = player_model.global_transform
	orientation.origin = Vector3()
	
	hud = hud_scn.instantiate()
	add_child(hud)
	
	inventory_component.set_inventory_menu()
	inventory_menu = inventory_component.inventory_menu
	
	ability_system_component.add_startup_abilities()
	
	_connect_signals()

func _connect_signals():
	inventory_component.on_no_room_in_inventory.connect(hud.show_interact_message.bind("NO ROOM IN INVENTORY"))
	inventory_component.connect_add_item()
	inventory_component.inv_hover_item_created.connect(hud.add_hover_item)
	
	ability_system_component.animate_ability.connect(animate_one_shots)
	
	_connect_ability_input_signals()
	
func _connect_ability_input_signals():
	player_input.ability_1_pressed.connect(ability_system_component.handle_input)
	player_input.ability_2_pressed.connect(ability_system_component.handle_input)
	player_input.ability_3_pressed.connect(ability_system_component.handle_input)
	player_input.ability_4_pressed.connect(ability_system_component.handle_input)
	player_input.basic_attack_pressed.connect(ability_system_component.handle_input)
	player_input.secondary_attack_pressed.connect(ability_system_component.handle_input)
	player_input.dodge_pressed.connect(ability_system_component.handle_input)
	player_input.jump_pressed.connect(ability_system_component.handle_input)
	
func _process(delta: float):
	if !UPDATE_ON_PHYSICS:
		_handle_input(delta) # Handle player input
	_trace_for_item()
	
	_debug_timer()
	
func _physics_process(delta: float) -> void:
	_handle_input(delta)
	
	animate("state", delta)
	
	
func animate(animation : String, delta:= 0.0):
	anim_tree.set("parameters/IdleWalkRun/conditions/move", is_on_floor() and velocity.length() > 0)
	anim_tree.set("parameters/IdleWalkRun/conditions/idle", is_on_floor() and velocity.length() < 0.5)
	anim_tree.set("parameters/conditions/jump", not is_on_floor())
	anim_tree.set("parameters/conditions/landed", is_on_floor())
	
func animate_one_shots(animation : String, time : float):
	anim_tree.set("parameters/Dodge/dodge/action_speed/scale", time)
	anim_tree.set("parameters/conditions/dodge", animation == "dash")
	
func _handle_input(delta: float):
	motion = motion.lerp(player_input.motion, MOTION_INTERP_SPEED * delta)
	
	var camera_basis : Basis = player_input.get_camera_rotation_basis()
	var camera_z := camera_basis.z
	var camera_x := camera_basis.x
	
	camera_z.y = 0
	camera_z = camera_z.normalized()
	camera_x.y = 0
	camera_x = camera_x.normalized()
	
	var target : Vector3 = camera_x * motion.x + camera_z * motion.y
	if target.length() > 0.1:
		var q_from = orientation.basis.get_rotation_quaternion()
		var q_to = Transform3D().looking_at(target, Vector3.UP).basis.get_rotation_quaternion()
		orientation.basis = Basis(q_from.slerp(q_to, delta * MOTION_INTERP_SPEED))

	## Root motion - unused at the moment
	root_motion = Transform3D(anim_tree.get_root_motion_rotation(), anim_tree.get_root_motion_position())
	orientation *= root_motion
	
	## Better way? This works
	if motion.length() > 0.1:
		var h_velocity = Vector3(-target.x, 0, target.z)
		velocity.x = h_velocity.x * movement_speed
		velocity.z = -h_velocity.z * movement_speed
	elif player_input.is_moving == false:
		velocity.x = 0
		velocity.z = 0


	if is_on_floor():
		state = State.RUN
	
		#Actions
	if Input.is_action_just_pressed("interact"):
		interact()
		
	if Input.is_action_just_pressed("debug"):
		InventoryStatics.debug_print_grid_slot_status(inventory_component.inventory_menu.grid_equippable)
		
	if Input.is_action_just_pressed("inventory"):
		inventory_component.toggle_inventory()
		
	if Input.is_action_just_pressed("escape"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	if !is_on_floor() and gravity_toggle:
		velocity += gravity
		state = State.FALLING
	
	set_velocity(velocity)
	set_up_direction(Vector3.UP)
	move_and_slide()
	
	orientation.origin = Vector3()
	orientation = orientation.orthonormalized()
	
	player_model.global_transform.basis = orientation.basis
		

		
func interact():
	if is_instance_valid(this_target) and InventoryStatics.has_item_component(this_target):
		inventory_component.try_add_item(this_target.item_component)
		this_target.item_component.on_picked_up()
		print("Inventory item list: ", inventory_component.inventory_list)

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
				var interact_actions = InputMap.action_get_events("interact")
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

		print(velocity)
		debug_timer_exists = false
