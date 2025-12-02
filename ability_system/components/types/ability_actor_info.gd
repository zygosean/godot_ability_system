class_name AbiliyActorInfo extends Resource

var owner_actor : Node3D # Character
var avatar_actor : Node3D # Visual model of Character
var asc : AbilitySystemComponent
var player_controller : Node # Input - if needed

func init_from_actor(in_owner_actor : Node3D, in_avatar_actor : Node3D, in_asc : AbilitySystemComponent):
	owner_actor = in_owner_actor
	avatar_actor = in_avatar_actor
	asc = in_asc
	
	# can get an "affected anim instance tag" -> Godot comparable? - here
	
	if owner_actor is Player:
		player_controller = owner_actor.player_input
