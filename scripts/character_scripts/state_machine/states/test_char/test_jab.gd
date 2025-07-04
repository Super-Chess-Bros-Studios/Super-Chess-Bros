extends CharacterState
class_name TestJab

@export var jab_hitbox : Hitbox

var jab_ended = false

func Enter():
	print("Jab State")
	jab_ended = false
	playanim("jab")

func end_of_jab():
	jab_ended = true

func Physics_Update(_delta: float):
	if char_attributes.just_took_damage:
		jab_hitbox.deactivate_hitbox()
		Transitioned.emit(self,"hitstun")
	elif !character.is_on_floor():
		jab_hitbox.deactivate_hitbox()
		Transitioned.emit(self,"fall")
	elif jab_ended:
		Transitioned.emit(self, "idle")
	else:
		character.velocity.x = lerp(character.velocity.x, 0.0, char_attributes.FRICTIONLERP)
		character.move_and_slide()
