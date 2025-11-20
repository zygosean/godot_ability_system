## Basic dodge - impulse based on movement direction
class_name BasicDodgeAbility extends DodgeAbility

@export var dodge_impulse : float = 30

func activate(component : AbilitySystemComponent):
	var asc_owner := AbilitySystemStatics.get_asc_owner(component)
	if asc_owner == null: return
	
	if asc_owner is CharacterBody3D:
		asc_owner.velocity = asc_owner.velocity * dodge_impulse
	
	
