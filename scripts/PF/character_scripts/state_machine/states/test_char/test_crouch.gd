extends CharacterState
class_name TestCrouch

func Enter():
	print("Crouch state")
	playanim("crouch")

func Physics_Update(delta):
	if char_attributes.just_took_damage:
		Transitioned.emit(self, "hitfreeze")
	elif !character.is_on_floor():
		Transitioned.emit(self,"fall")
	elif !Input.is_action_pressed(get_action("down")):
		Transitioned.emit(self,"idle")
	elif Input.is_action_pressed(get_action("jump")):
		Transitioned.emit(self, "jumpsquat")
	else:
		character.velocity.x -= lerp(character.velocity.x, 0.0, char_attributes.FRICTIONLERP)
		character.move_and_slide()
