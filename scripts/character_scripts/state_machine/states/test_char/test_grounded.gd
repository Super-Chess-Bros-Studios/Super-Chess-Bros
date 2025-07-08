extends TestIdle
class_name TestGrounded

@export var landing_lag : Timer

var grounded_end = false

func Enter():
	print("Grounded state")
	#refreshes the character's ability to air dodge and double jump
	char_attributes.can_double_jump = true
	char_attributes.can_air_dodge = true
	char_attributes.can_wall_jump = true
	grounded_end = false
	landing_lag.start(char_attributes.landing_lag_length)
	playanim("grounded")

func end_grounded():
	char_attributes.landing_lag_length = 0
	grounded_end = true

func Physics_Update(delta):
	if char_attributes.just_took_damage:
		Transitioned.emit(self, "hitfreeze")
	elif !character.is_on_floor():
		Transitioned.emit(self,"fall")
	else:
		#if you're not moving quick enough, stop skidding
		if grounded_end:
			Transitioned.emit(self,"idle")
		character.velocity.x = lerp(character.velocity.x, 0.0, char_attributes.FRICTIONLERP)
		character.move_and_slide()
