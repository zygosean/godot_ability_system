## Manages abilities and input - gives startup abilities and manages ability activation
class_name AbilitySystemComponent extends Node

@export var startup_abilities : Array[AbilityBase]
@export var attributes : Array[AttributeBase]

var attribute_set : AttributeSetBase
var abilities : Array[AbilityBase]


func handle_input(event):
	for ability in abilities:
		var input_found : AbilityBase.AbilityInputSlot = AbilitySystemStatics.get_input_from_string(event)
		if input_found == AbilityBase.AbilityInputSlot.NONE: return
		if input_found == ability.input_action:
			activate_ability(ability)

func activate_ability(activate : AbilityBase):
	if activate.is_on_cooldown() or activate.in_action == true:
		# handle cooldown/action separately (action speed can be like cast speed, fire after x seconds
		return
	activate.activate(self)
	activate.in_action = true
	action_timer(activate)

func _ability_activated(ability : AbilityBase):
	print("Do something here")

func add_startup_abilities():
	abilities.assign(startup_abilities)
	for ability in abilities:
		ability.connect("ability_activated", _ability_activated)
	print("Size of startup array: ", startup_abilities.size())
	print("Size of abilities array: ", abilities.size())
	
func _assign_ability_to_slot(new_ability : AbilityBase, input : AbilityBase.AbilityInputSlot):
	var found_ability : AbilityBase = null
	for ability in abilities:
		if ability.input_action == input:
			# need logic for switching (ex: moving between bars)
			found_ability = ability
	if found_ability != null:
		abilities.append(new_ability)
		
func action_timer(ability : AbilityBase):
	await get_tree().create_timer(ability.action_speed).timeout
	ability.in_action = false
