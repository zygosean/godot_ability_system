class_name CharacterStateComponent extends Node

@export var state_machine_path : NodePath
@export var asc_path : NodePath

@onready var state_machine : StateMachine = $StateMachine
@onready var ability_system_component : AbilitySystemComponent = $AbilitySystemComponent

func _ready():
	print("Children: ", get_children())
	state_machine.init(self)
	ability_system_component.init(self)
	
	#if is_instance_valid(ability_system_component):
		#ability_system_component.startup_abilities = startup_abilities
		#ability_system_component.add_startup_abilities()

func get_current_state() -> State:
	if is_instance_valid(state_machine):
		return state_machine.current_state
	return null
