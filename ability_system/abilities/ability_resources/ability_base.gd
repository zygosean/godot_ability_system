class_name AbilityBase extends Resource

signal ability_activated(ability : AbilityBase, msg : Dictionary)
signal request_spawn(global_xform : Transform3D, params : ProjectileEffectParams)
signal activate_test(callable : Callable)

# enums for requirements?
enum AbilityType { WEAPON, SPELL, MOVEMENT }
enum AbilityInputSlot { BASIC, SECONDARY, ONE, TWO, THREE, FOUR, DODGE, JUMP, NONE}

@export var cost : float = 0.0
@export var cooldown : float = 0.0
@export var action_speed : float = 1.0
@export var action_time : float = 1.0
@export var input_action : AbilityInputSlot = AbilityInputSlot.NONE

# Animations
@export_subgroup("Animation")
@export var anim_name : String

# Can have this only show by using a @tool node
@export_subgroup("Damage") # remove this -> damage exists on DamageEffectParam
@export var min_damage : float = 0.0
@export var max_damage : float = 0.0

var in_action : bool = false

## Child resource to contain activation logic
func activate(component : AbilitySystemComponent):
	emit_signal("ability_activated", self, {})
	
func _apply_effect(component : AbilitySystemComponent, attribute_set : AttributeSetBase):
	pass
		
func is_on_cooldown() -> bool:
	return false
	
func trigger_timer(owning_asc : AbilitySystemComponent, time : float) -> bool:
	await owning_asc.get_tree().create_timer(time).timeout
	return false
	
func on_ability_added(owning_asc : AbilitySystemComponent):
	pass
