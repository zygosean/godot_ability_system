class_name DisplayMessage extends Control

@onready var message := $Message

func set_message(text : String):
	message.text = text

func show_message():
	self.show()
	modulate.a =  0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1, 0.5)
	
func hide_message():
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0, 0.5)
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(hide)
	timer.start()
