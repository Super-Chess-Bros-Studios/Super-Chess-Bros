extends CharacterState
class_name TestUpSpecial

@export var timer : Timer

@export var speed : float = 300

func Enter():
	print("Up Special state")
	character.velocity.y = char_attributes.JUMP_POWER
	timer.start()
	playanim("up_special")

func Physics_Update(delta):
	if character.is_on_floor():
		Transitioned.emit(self,"idle")
	elif timer.is_stopped():
		Transitioned.emit(self, "SpecialFall")
	
	#handles horizontal events
	elif Input.is_action_pressed(get_action("left")):
			character.velocity.x = lerp(character.velocity.x,-speed,char_attributes.AIRSPEEDLERP)
			character.move_and_slide()
	elif Input.is_action_pressed(get_action("right")):
			character.velocity.x = lerp(character.velocity.x,speed,char_attributes.AIRSPEEDLERP)
			character.move_and_slide()
	else:
		character.move_and_slide()
