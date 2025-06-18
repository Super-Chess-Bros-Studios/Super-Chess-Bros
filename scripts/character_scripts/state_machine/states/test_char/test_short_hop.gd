extends TestFullHop
class_name TestShortHop

@export var jump_power_coefficient = 0.65

func Enter():
	print("Short hop state")
	character.velocity.y = char_attributes.JUMP_POWER * jump_power_coefficient
	var leftCollide = false
	var rightCollide = false
	wall_detection_enabled(true)
	#basically this variant applies to double jump
	if !char_attributes.can_double_jump:
		character.velocity.y *= double_jump_coefficient
	playanim()

func Exit():
	wall_detection_enabled(false)
