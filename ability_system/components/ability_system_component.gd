## Manages abilities and input - gives startup abilities and manages ability activation
class_name AbilitySystemComponent extends Node

@export var startup_abilities : Array[AbilityBase]

var attribute_set : AttributeSetBase
var abilities : Array[AbilityBase]
#
#func _unhandled_input(event):
	## check owner
	#if event is InputEventAction and event.pressed:
		#print (event)
		#for ability in abilities:
			#var input_found = AbilitySystemStatics.get_input_from_string(event.action)
			#if input_found == AbilityBase.AbilityInputSlot.NONE: return
			#activate_ability(ability)
			
func handle_input(event):

	for ability in abilities:
		var input_found = AbilitySystemStatics.get_input_from_string(event)
		if input_found == AbilityBase.AbilityInputSlot.NONE: return
		activate_ability(ability)

func activate_ability(activate : AbilityBase):
	for ability in abilities:
		if ability is not AbilityBase: return
		if ability.is_on_cooldown():
			print(ability, " is on cooldown!")
			return
		ability.activate(self)

func add_startup_abilities():
	abilities.assign(startup_abilities)
	
func _assign_ability_to_slot(new_ability : AbilityBase, input : AbilityBase.AbilityInputSlot):
	var found_ability : AbilityBase = null
	for ability in abilities:
		if ability.input_action == input:
			# need logic for switching (ex: moving between bars)
			found_ability = ability
	if found_ability != null:
		abilities.append(new_ability)
