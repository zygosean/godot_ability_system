## Basic jump
class_name JumpAbility extends AerialAbility

@export var jump_velocity : float = 45
#@export var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity") * ProjectSettings.get_setting("physics/3d/default_gravity_vector")

func activate(component : AbilitySystemComponent):
	var asc_owner : CharacterBody3D = AbilitySystemStatics.get_asc_owner(component)
	if asc_owner == null: return
	if asc_owner is Player:
		if not asc_owner.is_on_floor(): return
		asc_owner.gravity_toggle = false
		asc_owner.velocity.y = jump_velocity
		await asc_owner.get_tree().create_timer(0.3)
		asc_owner.gravity_toggle = true
	
