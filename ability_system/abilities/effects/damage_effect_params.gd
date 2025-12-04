## In UE, AuraAbilityTypes (which holds DamageParams) contains the NetSerialize function - attaching this script to a multiplayerSynchronizer?
class_name DamageEffectParams extends EffectParams

@export var base_damage : float = 0.0
@export var damage_type : StringName # change this
@export var is_radial_damage : bool = false # this on the ability itself?

# death impulse
@export var death_impulse_mag : float = 0.0
@export var death_impulse_vec : Vector3 = Vector3.ZERO

func apply_effect():
	pass
