class_name AbilityBase extends Resource

signal ability_activated(ability : AbilityBase)

# enums for requirements?
enum AbilityType { WEAPON, SPELL, MOVEMENT }
enum AbilityInputSlot { BASIC, SECONDARY, ONE, TWO, THREE, FOUR, DODGE, JUMP, NONE}

@export var cost : float = 0.0
@export var cooldown : float = 0.0
@export var input_action : AbilityInputSlot = AbilityInputSlot.NONE

## Child resource to contain activation logic
func activate(component : AbilitySystemComponent):
	pass
	
func _apply_effect(component : AbilitySystemComponent, attribute_set : AttributeSetBase):
	pass

func is_on_cooldown() -> bool:
	return false
