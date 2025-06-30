extends CharacterState
class_name TestJumpSquat

var short_hop = false

func Enter():
	print("Jumpsquat state")
	short_hop = false
	playanim("jumpsquat")

func end_jumpsquat():
	if Input.is_action_pressed(get_action("shield")):
		Transitioned.emit(self, "airdodge")
	elif short_hop:
		Transitioned.emit(self, "shorthop")
	else:
		Transitioned.emit(self, "fullhop")

func Update(delta):
	if Input.is_action_just_released(get_action("jump")):
		short_hop = true

func Physics_Update(delta):
	character.velocity.x = lerp(character.velocity.x, 0.0, char_attributes.FRICTIONLERP)
	character.move_and_slide()
