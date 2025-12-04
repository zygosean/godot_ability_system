extends Node3D

@onready var level_test_scene := preload("res:///level/level_test.tscn")
@onready var player_scene := preload("res://player/player.tscn")

# TODO: This should likely go in the "start game" sub-routines
@onready var hud_scene := preload("res://inventory/UI/HUD/HUD.tscn")

func _ready():
	var level_test := level_test_scene.instantiate()
	add_child(level_test)
	
	var player_test := player_scene.instantiate()
	level_test.add_child(player_test)
	
	player_test.position = Vector3(0,5,0)
