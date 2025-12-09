class_name FireballAbility extends SpellAbility # do i want this to be a projectile

@export var projectile_params : ProjectileEffectParams
@export var damage_params : DamageEffectParams
@export var aoe_params : AOEEffectParams
@export var debuff_params : DebuffEffectParams

var temp_spread :int = 1

func activate(component : AbilitySystemComponent):
	super(component)
	var asc_owner : Node3D = AbilitySystemStatics.get_asc_owner(component)
	if asc_owner == null: return
	
	if asc_owner is Player:
		# turn character to forward camera dir
		var target_loc : Vector3 = asc_owner.trace_for_target()
		
		var direction : Vector3 = (target_loc - asc_owner.proj_spawn_marker.global_position).normalized()
		
		for i in range(0, temp_spread):
			var pos = asc_owner.proj_spawn_marker.global_position
			pos.x = pos.x + i
			var global_xform : Transform3D = Transform3D(Basis.looking_at(direction, Vector3.UP), pos)
			#EffectSpawner.spawn_projectile(pos, direction, projectile_params)
			emit_signal("request_spawn", pos, direction, projectile_params)
			var callable : Callable = Callable(self, "on_activate_callable")
			emit_signal("activate_test", callable)
		
	# cooldown already checked in ability_system_component, therefore can activate()
	# need to spawn projectile -> should be in projectile component
	
func on_ability_added(component : AbilitySystemComponent):
	super(component)
	var asc_owner : Node3D = AbilitySystemStatics.get_asc_owner(component)
	if asc_owner == null: return
	
	if asc_owner is Player: # would be nice to decouple this
		pass
		
func on_activate_callable(spawner : Spawner) -> Node3D:
	if not is_instance_valid(spawner): return null
	
	spawner.spawn()
