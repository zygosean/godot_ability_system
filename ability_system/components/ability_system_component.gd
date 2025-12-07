## Manages abilities and input - gives startup abilities and manages ability activation
class_name AbilitySystemComponent extends Node

signal animate_ability(anim_name : String, time : float)
signal override_locomotion(duration : float)
signal ability_activated

@export var startup_abilities : Array[AbilityBase]
@export var attributes : Array[AttributeBase]

var attribute_set : AttributeSetBase
var abilities : Array[AbilityBase]

var char_state : CharacterStateComponent

func init(char_state_comp : CharacterStateComponent):
	char_state = char_state_comp

func handle_input(event : StringName):
	
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
	if not activate.anim_name.is_empty():
		emit_signal("animate_ability", activate.anim_name, activate.action_speed)
	action_timer(activate)
	emit_signal("ability_activated")

func _ability_activated(ability : AbilityBase):
	pass

func add_startup_abilities():
	abilities.assign(startup_abilities)
	for ability in abilities:
		ability.connect("ability_activated", _ability_activated)
		ability.on_ability_added(self)
	
func _assign_ability_to_slot(new_ability : AbilityBase, input : AbilityBase.AbilityInputSlot):
	var found_ability : AbilityBase = null
	for ability in abilities:
		if ability.input_action == input:
			# need logic for switching (ex: moving between bars)
			found_ability = ability
	if found_ability != null:
		abilities.append(new_ability)
		new_ability.on_ability_added(self)
		
func action_timer(ability : AbilityBase):
	await get_tree().create_timer(ability.action_speed).timeout
	ability.in_action = false
	
func apply_effects_to_self(params : Array[EffectParams]):
	pass
