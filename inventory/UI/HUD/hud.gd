## Main HUD class added to player.
## Extends control
class_name HUD extends Control

## Message classes, set in ready
## Message classes extend Control nodes with a Label (message)
var display_message : DisplayMessage
var interact_message : DisplayMessage
var interact_timer : Timer

## Label set to the center of the screen
@onready var crosshairs := $Crosshairs
@onready var cursor := $Cursor

## Message class scenes
@onready var display_message_scn := load("res://inventory/UI/message/display_message.tscn")


## Instantiates and adds message classes. Sets
func _ready():
	display_message = display_message_scn.instantiate()
	add_child(display_message)
	interact_message = display_message_scn.instantiate()
	add_child(interact_message)
	
	var screen : Vector2 = get_window().get_size()
	display_message.position = Vector2(display_message.position.x, screen.y / 3)
	interact_message.position = Vector2(interact_message.position.x, - screen.y / 3)
	
	display_message.hide()
	interact_message.hide()
	cursor.hide()
	
func _process(delta): 
	cursor.set_position(get_local_mouse_position())

func add_hover_item(hover_item : HoverItem):
	cursor.add_child(hover_item)
	cursor.show()

func set_display_message(str : String, should_display : bool):
	display_message.message.text = str
	if should_display == true:
		display_message.show_message()

func hide_message(msg : Control):
	msg.message.text = ""
	
func show_interact_message(str : String):
	interact_message.message.text = str
	interact_message.show()
	if is_instance_valid(interact_timer):
		interact_timer.start()
	else:
		interact_timer = Timer.new()
		interact_timer.wait_time = 1.5
		interact_timer.one_shot = true
		add_child(interact_timer)
		interact_timer.timeout.connect(hide_message.bind(interact_message))
		interact_timer.start()
	
	
