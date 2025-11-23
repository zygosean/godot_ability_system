## Basic dodge - impulse based on movement direction
class_name BasicDodgeAbility extends DodgeAbility

@export var dodge_impulse : float = 30

func activate(component : AbilitySystemComponent):
	super.activate(component)
	var asc_owner := AbilitySystemStatics.get_asc_owner(component)
	if asc_owner == null: return
	
	if asc_owner is not CharacterBody3D: return
	if asc_owner is Player:
		if asc_owner.velocity.length() > 0.01:
			asc_owner.velocity = asc_owner.velocity * dodge_impulse
		elif asc_owner.velocity.length() < 0.01:
			# need to get the model transform here, not the Player
			
			asc_owner.velocity = -asc_owner.orientation.basis.z * dodge_impulse
	
	
