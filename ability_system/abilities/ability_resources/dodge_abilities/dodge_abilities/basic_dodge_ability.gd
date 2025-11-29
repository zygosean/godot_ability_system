## Basic dodge - impulse based on movement direction
class_name BasicDodgeAbility extends DodgeAbility

@export var dodge_impulse : float = 30

func activate(component : AbilitySystemComponent):
	super.activate(component)
	var asc_owner := AbilitySystemStatics.get_asc_owner(component)
	if asc_owner == null: return
	
	if asc_owner is not CharacterBody3D: return
	if asc_owner is not Player: return
	
	var player := asc_owner as Player
	var dir : Vector3
	
	if player.velocity.length() > 0.01:
		dir = player.velocity
		dir.y = 0.0
		dir = dir.normalized()
	elif asc_owner.velocity.length() < 0.01:
		dir = -asc_owner.orientation.basis.z
		dir.y = 0.0
		dir = dir.normalized()
	var is_dodging : bool = true
	var dodge_vel = dir * dodge_impulse
	emit_signal("initiate_dodge", is_dodging, dodge_vel, dodge_time)
	
