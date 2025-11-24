## Parent for weapon abilities
class_name WeaponAbility extends AbilityBase

enum WeaponType { SWORD, RIFLE, HAMMER, UNARMED }

@export var uses_ammo : bool = false

# Gather information from the weapon and set things like damage, damage types, etc
