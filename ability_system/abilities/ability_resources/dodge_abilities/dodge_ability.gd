## Parent class for Dodge-type abilities
class_name DodgeAbility extends AbilityBase

@export var dodge_time : float

func activate(component : AbilitySystemComponent):
	var owner : CharacterBase = AbilitySystemStatics.get_asc_owner(component)
	var dir : Vector3 = owner.velocity
	emit_signal("ability_activated", self)
	
