## Basic jump
class_name JumpAbility extends AerialAbility

@export var jump_velocity : float = 8.0
#@export var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity") * ProjectSettings.get_setting("physics/3d/default_gravity_vector")

func activate(component : AbilitySystemComponent):
	var asc_owner : CharacterBody3D = AbilitySystemStatics.get_asc_owner(component)
	if asc_owner == null: return
	
	asc_owner.velocity.y = jump_velocity
	
