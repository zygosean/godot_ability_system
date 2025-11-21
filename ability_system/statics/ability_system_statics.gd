class_name AbilitySystemStatics extends Object

enum FragmentTags{ NAME, AMMO, ICON, ANIMATION }

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

## returns the owner of the Ability System Component
static func get_asc_owner(component : AbilitySystemComponent) -> Node3D:
	return component.owner as Node3D
	
## Only loops over TWO iterations of children, doesn't recursively search the tree
static func get_owner_anim_player(owner : Node3D) -> AnimationPlayer:
	for child in owner.get_children():
		if child.get_children().size() > 0:
			var grand_children = child.get_children()
			for grand_child in grand_children:
				if grand_child is AnimationPlayer:
					return grand_child
		if child is AnimationPlayer:
			return child
	return null
