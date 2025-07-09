extends CharacterState
class_name TestAirDodge

@export var speed : float = 300
var directional_input : Vector2

var air_dodge_end = false

func Enter():
	print("Air dodge state")
	air_dodge_end = false
	directional_input = Input.get_vector(get_action("left"),get_action("right"),get_action("up"),get_action("down")).normalized()
	char_attributes.invulnerable = true
	char_attributes.can_air_dodge = false
	playanim("airdodge")

func end_air_dodge():
	air_dodge_end = true

func Exit():
	char_attributes.invulnerable = false

func Physics_Update(delta):
	if character.is_on_floor():
		char_attributes.landing_lag_length = 0.1
		Transitioned.emit(self,"grounded")
	elif air_dodge_end:
		#might add a transition to ground if grounded but i wanna see this first
		Transitioned.emit(self, "fall")
	else:
		character.velocity = directional_input * speed
		character.move_and_slide()
