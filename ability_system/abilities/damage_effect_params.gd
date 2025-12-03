## In UE, AuraAbilityTypes (which holds DamageParams) contains the NetSerialize function - attaching this script to a multiplayerSynchronizer?
class_name DamageEffectParams extends Resource

var source_asc : AbilitySystemComponent
var target_asc : AbilitySystemComponent
var base_damage : float = 0.0
var ability_level : int = 1
var damage_type : StringName # change this

# debug
var debuff_chance : float = 0.0
var debuff_duration : float = 0.0
var debuff_freq : float = 0.0
var debuff_damage: float = 0.0

# death impulse
var death_impulse_mag : float = 0.0
var death_impulse_vec : Vector3 = Vector3.ZERO

#knockback
var knockback_force_mag : float = 0.0
var knockback_chance : float = 0.0
var knockback_force_vec : Vector3 = Vector3.ZERO

var is_radial_damage : bool = false
var radial_damage_outer_radius : float = 0.0
var radial_damage_inner_radius : float = 0.0
var radial_damage_origin : Vector3 = Vector3.ZERO
