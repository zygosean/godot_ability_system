## Parent class for Dodge-type abilities
class_name DodgeAbility extends AbilityBase

signal initiate_dodge(is_dodging : bool, dodge_vel : float, dodge_time : float)

var dodge_time : float

@export var invuln_time : float
