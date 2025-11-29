## Manages abilities and input - gives startup abilities and manages ability activation
class_name AbilitySystemComponent extends Node

signal animate_ability(anim_name : String, time : float)
signal dodge_ability_activate(is_active : bool, invuln_time : int)
signal change_owner_state(state : Player.MoveState)

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
			
# We don't want to change state via child - we want the "State Machine" to determine state based on 
# the parameters provided by children.
func handle_dodge_ability(success : bool, dodge_vel : Vector3, dodge_time : float):
	emit_signal("change_owner_state", Player.MoveState.DODGE)
	await get_tree().create_timer(dodge_time).timeout
	emit_signal("change_owner_state", Player.MoveState.LOCOMOTION)

func activate_ability(activate : AbilityBase):
	if activate.is_on_cooldown() or activate.in_action == true:
		# handle cooldown/action separately (action speed can be like cast speed, fire after x seconds
		return
	activate.activate(self)
	activate.in_action = true
	if not activate.anim_name.is_empty():
		emit_signal("animate_ability", activate.anim_name, activate.action_speed)
	action_timer(activate)

func _ability_activated(ability : AbilityBase):
	if ability is DodgeAbility:
		emit_signal("dodge_ability_activate", true, ability.action_speed)

func add_startup_abilities():
	abilities.assign(startup_abilities)
	for ability in abilities:
		ability.connect("ability_activated", _ability_activated)
		if ability is DodgeAbility:
			ability.initiate_dodge.connect(handle_dodge_ability)
	
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
	
	
