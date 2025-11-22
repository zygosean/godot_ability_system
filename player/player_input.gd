extends MultiplayerSynchronizer


@export_subgroup("Movement")
@export var movement_speed : float = 10.0
@export var sprint_multi : float = 1.5

@export_subgroup("Mouse")
@export var CAMERA_CONTROLLER_ROT_SPEED := 5.0
@export var MOUSE_ACCEL_STATE : bool = true
@export var CAMERA_SENS : float = 0.005
@export var MOUSE_ACCEL : float = 50
@export var MOUSE_INVERT : bool = true
@export var PLAYER_TURN_SPEED : float = 10

@export_subgroup("Clamp Head Rotation")
@export var CLAMP_HEAD_ROTATION := false # Enable head rotation clamping
@export var CLAMP_HEAD_ROTATION_MIN := -80.0 # Min head rotation
@export var CLAMP_HEAD_ROTATION_MAX := 80.0 # Max head rotation

@export_subgroup("Set Camera")
@export var camera_base : Node3D
@export var camera_rot : Node3D
@export var camera_camera : Camera3D
# for whole screen fade in/out
@export var colour_rect : Node3D

@export_subgroup("Synchronized Controls")
@export var motion : Vector2

@export_category("Multiplayer")
@export var player_id : int = 1 :
	set(value):
		player_id = value
		$InputSynchronizer.set_multiplayer_authority(value)

func _ready():
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		camera_camera.make_current()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		set_process(false)
		set_process_input(false)
		colour_rect.hide()
		

func _process(delta:float):
	motion = Vector2(Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
					Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward"))
	var camera_move = Vector2(Input.get_action_strength("view_right") - Input.get_action_strength("view_left"),
					Input.get_action_strength("view_up") - Input.get_action_strength("view_down"))
	var camera_speed_this_frame : float = delta * CAMERA_CONTROLLER_ROT_SPEED
	rotate_camera(camera_move * camera_speed_this_frame)

func _input(event):
	# Make mouse aiming speed resolution-independent
	# (required when using the `canvas_items` stretch mode).
	var scale_factor: float = min(
			(float(get_viewport().size.x) / get_viewport().get_visible_rect().size.x),
			(float(get_viewport().size.y) / get_viewport().get_visible_rect().size.y)
	)

	if event is InputEventMouseMotion:
		var camera_speed_this_frame = CAMERA_SENS
		rotate_camera(event.relative * camera_speed_this_frame * scale_factor)
		
		
func rotate_camera(move : Vector2):
	camera_base.rotate_y(-move.x)
	camera_base.rotate_x(move.y)
	camera_rot.rotation.x = clamp(camera_rot.rotation.x + move.y, CLAMP_HEAD_ROTATION_MIN, CLAMP_HEAD_ROTATION_MAX)
