## Required modules: ability_system, inventory
class_name Player extends CharacterBody3D

signal highlight
signal unhighlight

enum State { IDLE, RUN, JUMP, DODGE, CASTING, FALLING }

@export_subgroup("Movement")
@export var MOVE_FORWARD : String = "move_forward"
@export var MOVE_BACKWARD : String = "move_backward"
@export var MOVE_RIGHT : String = "move_right"
@export var MOVE_LEFT : String = "move_left"
@export var movement_speed : float = 10.0
@export var sprint_multi : float = 1.5

@export_subgroup("Abilities")
@export var BASIC_ATTACK : String = "basic_attack"
@export var SECONDARY_ATTACK : String = "secondary_attack"
@export var ABILITY_1 : String = "ability_1"
@export var ABILITY_2 : String = "ability_2"
@export var ABILITY_3 : String = "ability_3"
@export var ABILITY_4 : String = "ability_4"
@export var DODGE : String = "dodge"
@export var JUMP : String = "jump"

@export_subgroup("Actions")
@export var INTERACT : String = "interact"
@export var DEBUG : String = "debug"
@export var INVENTORY : String = "inventory"

@export_subgroup("Mouse")
@export var MOUSE_ACCEL_STATE : bool = true
@export var MOUSE_SENS : float = 0.005
@export var MOUSE_ACCEL : float = 50
@export var MOUSE_INVERT : bool = true
@export var PLAYER_TURN_SPEED : float = 10

@export_subgroup("Clamp Head Rotation")
@export var CLAMP_HEAD_ROTATION := false # Enable head rotation clamping
@export var CLAMP_HEAD_ROTATION_MIN := -80.0 # Min head rotation
@export var CLAMP_HEAD_ROTATION_MAX := 80.0 # Max head rotation

# Advanced Settings
@export_category("Advanced")
@export var UPDATE_ON_PHYSICS := true # Should the update happen on physics ticks?

# Inventory
@export_category("Inventory")
@export var inventory_menu : SpatialInventory

var move_direction := Vector3.ZERO
var rotation_target_yaw : float
var rotation_target_pitch : float
var motion : Vector2

var last_target
var this_target

var input : String
var gravity_test : float = 24.0
var hud : HUD

#Debugging in process
var debug_timer_exists : bool = false



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
	move_direction = camera_base.global_rotation
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	up_direction = Vector3.UP
	
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
	
	
func _process(delta: float):
	if !UPDATE_ON_PHYSICS:
		_handle_input(delta) # Handle player input
		rotate_player(delta) # Apply player and camera rotation
		
	_trace_for_item()
	
	_debug_timer()
	
func _physics_process(delta: float) -> void:
	_handle_input(delta)
	rotate_player(delta)
	
	animate(state, delta)
	
	
# State machine code could have all this in there, so then the match structure would just say JumpState.animate or something
func animate(animation : State, delta:= 0.0):
	anim_tree.set("parameters/IdleWalkRun/conditions/move", is_on_floor() and velocity.length() > 0)
	anim_tree.set("parameters/IdleWalkRun/conditions/idle", is_on_floor() and velocity.length() < 0.5)
	anim_tree.set("parameters/conditions/jump", not is_on_floor())
	anim_tree.set("parameters/conditions/landed", is_on_floor())
	
func _handle_input(delta: float):
	#var move_direction : Vector3 # Initial movement direction is zero
	#var cam_xform = camera.global_transform
	#var forward_flat = -cam_xform.basis.z
	#var right_flat = cam_xform.basis.x
	#forward_flat.y = 0
	#right_flat.y = 0
	#var forward = forward_flat.normalized()
	#var right = right_flat.normalized()
#
	#move_direction.z = Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
	#move_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	#move_direction = move_direction.normalized()
	#
	#var horizontal_velocity = (forward * move_direction.z + right * move_direction.x) * movement_speed
	#velocity.x = horizontal_velocity.x
	#velocity.z = horizontal_velocity.z
	## Faces player in direction of movement - Add lerp if desired
	#if horizontal_velocity.length() > 0.01:
		#var target = global_transform.origin - horizontal_velocity
		#target.y = 0
		#player_model.look_at(target, Vector3.UP)
	
	if is_on_floor():
		state = State.RUN
	
	# Abilities
	if Input.is_action_pressed("jump"):
		if not is_instance_valid(ability_system_component): return
		ability_system_component.handle_input("jump")
		state = State.JUMP
		
	if Input.is_action_pressed("dodge"):
		if not is_instance_valid(ability_system_component): return
		ability_system_component.handle_input("dodge")
		state = State.DODGE
	
	if Input.is_action_pressed("ability_1"):
		if not is_instance_valid(ability_system_component): return
		ability_system_component.handle_input("ability_1")
		
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
		
	if !is_on_floor():
		velocity += gravity
		state = State.FALLING
	
	set_up_direction(Vector3.UP)
	set_velocity(velocity)
	move_and_slide()

#
#func _input(event):
		## Process mouse motion when the mouse is captured
	#if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		#set_rotation_target(event.relative)
		
		
#func set_rotation_target(mouse_motion: Vector2):
	#if MOUSE_INVERT :
		#rotation_target_yaw += -mouse_motion.x * MOUSE_SENS
		#rotation_target_pitch += mouse_motion.y * MOUSE_SENS
	#else:
		#rotation_target_yaw += -mouse_motion.x * MOUSE_SENS
		#rotation_target_pitch += -mouse_motion.y * MOUSE_SENS
	#if CLAMP_HEAD_ROTATION:
		#rotation_target_pitch = clamp(rotation_target_pitch, deg_to_rad(CLAMP_HEAD_ROTATION_MIN), deg_to_rad(CLAMP_HEAD_ROTATION_MAX))
	
func rotate_player(delta):
	if MOUSE_ACCEL_STATE:
		# Apply spherical interpolation (slerp) for smooth rotation
		var current_quat = camera_base.quaternion
		var target_quat = Quaternion(Vector3.UP, rotation_target_yaw) * Quaternion(Vector3.RIGHT, rotation_target_pitch)
		camera_base.quaternion = target_quat
		self.quaternion = Quaternion(Vector3.UP, rotation_target_yaw)

		up_direction = Vector3.UP
	else:
		# If mouse acceleration is off, directly set to target rotation
		quaternion = Quaternion(Vector3.UP, rotation_target_yaw) * Quaternion(Vector3.RIGHT, rotation_target_pitch)
		

		
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

		#print()
		debug_timer_exists = false
