extends CharacterState
class_name TestJab

var jab_ended = false

func Enter():
	print("Jab State")
	jab_ended = false
	playanim("jab")

func end_of_jab():
	jab_ended = true

func Physics_Update(_delta: float):
	if jab_ended:
		Transitioned.emit(self, "idle")
	else:
		character.velocity.x = lerp(character.velocity.x, 0.0, char_attributes.FRICTIONLERP)
		character.move_and_slide()
