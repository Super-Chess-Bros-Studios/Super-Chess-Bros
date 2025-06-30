extends CharacterState
class_name TestJumpSquat

var short_hop = false
var jumpsquat_ended = false
func Enter():
	print("Jumpsquat state")
	jumpsquat_ended = false
	short_hop = false
	playanim("jumpsquat")

func end_jumpsquat():
	jumpsquat_ended = true

func Physics_Update(delta):
	if char_attributes.just_took_damage:
		Transitioned.emit(self, "hitstun")
	elif Input.is_action_just_released(get_action("jump")):
		short_hop = true
	elif jumpsquat_ended:
		if Input.is_action_just_pressed(get_action("shield")):
			Transitioned.emit(self, "airdodge")
		elif short_hop:
			Transitioned.emit(self, "shorthop")
		else:
			Transitioned.emit(self, "fullhop")
	else:
		character.velocity.x = lerp(character.velocity.x, 0.0, char_attributes.FRICTIONLERP)
		character.move_and_slide()
