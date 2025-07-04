extends CharacterState
class_name TestIdle
#just so it doesnt repeat the beginning of the idle animation over and over in physics process
var idle_anim = true

func Enter():
	print("Idle state")
	#refreshes the character's ability to air dodge and double jump
	char_attributes.can_double_jump = true
	char_attributes.can_air_dodge = true
	char_attributes.can_wall_jump = true
	#.length returns the velocity as an absolute value
	#if you're moving fast enough, start skidding
	if character.velocity.length() > 50:
		playanim("skid")
		idle_anim = false
	else:
		idle_anim = true
		playanim("idle")

func Physics_Update(delta):
	
	if char_attributes.just_took_damage:
		Transitioned.emit(self, "hitstun")
	#bunch of inputs
	elif !character.is_on_floor():
		Transitioned.emit(self,"fall")
	elif Input.is_action_just_pressed(get_action("attack")):
		Transitioned.emit(self,"Jab")
	elif Input.is_action_pressed(get_action("up")) and Input.is_action_just_pressed(get_action("special")):
		Transitioned.emit(self,"UpSpecial")
	elif Input.is_action_pressed(get_action("left")):
		char_attributes.cur_dir = DIRECTION.left
		Transitioned.emit(self,"initialdash")
	elif Input.is_action_pressed(get_action("right")):
		char_attributes.cur_dir = DIRECTION.right
		Transitioned.emit(self,"initialdash")
	elif Input.is_action_pressed(get_action("down")):
		Transitioned.emit(self,"crouch")
	elif Input.is_action_pressed(get_action("jump")):
		Transitioned.emit(self, "JumpSquat")
	else:
		#if you're not moving quick enough, stop skidding
		if character.velocity.length() < 50:
			idle_anim = true
			playanim("idle")
		character.velocity.x = lerp(character.velocity.x, 0.0, char_attributes.FRICTIONLERP)
		character.move_and_slide()
