class_name UnarmedAbility extends WeaponAbility

func activate(component : AbilitySystemComponent):
	super.activate(component)
	emit_signal("ability_activated", self)
