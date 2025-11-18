class_name AbilitySystemStatics extends Object

static func get_input_from_string(action : StringName) -> AbilityBase.AbilityInputSlot:
	match action:
		"basic_attack":
			return AbilityBase.AbilityInputSlot.BASIC
		"secondary_attack":
			return AbilityBase.AbilityInputSlot.SECONDARY
		"ability_1":
			return AbilityBase.AbilityInputSlot.ONE
		"ability_2":
			return AbilityBase.AbilityInputSlot.TWO
		"ability_3":
			return AbilityBase.AbilityInputSlot.THREE
		"ability_4":
			return AbilityBase.AbilityInputSlot.FOUR
		"dodge":
			return AbilityBase.AbilityInputSlot.DODGE
		"jump":
			return AbilityBase.AbilityInputSlot.JUMP
	return AbilityBase.AbilityInputSlot.NONE
