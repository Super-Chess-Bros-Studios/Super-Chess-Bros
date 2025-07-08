extends CharacterState
class_name TestPivot

#I use this timed_out variable so I don't cause a race condition
var pivot_end = false

func Enter():
	print("Pivot state")
	char_attributes.cur_dir *= -1
	pivot_end = false
	playanim("pivot")

func end_pivot():
	pivot_end = true

func Physics_Update(delta):
	
	if char_attributes.just_took_damage:
		Transitioned.emit(self, "hitfreeze")
	elif !character.is_on_floor():
		Transitioned.emit(self,"fall")
	
	#Every statement needs to be elif so we don't emit multiple transitioned signals.
	
	#Only allow these movements once pivot ends.
	elif pivot_end:
		#If you're holding left at the end of pivot, run left.
		if Input.is_action_pressed(get_action("left")):
			char_attributes.cur_dir = DIRECTION.left
			Transitioned.emit(self,"initialdash")
		#If you're holding right at the end of pivot, run right.
		elif Input.is_action_pressed(get_action("right")):
			char_attributes.cur_dir = DIRECTION.right
			Transitioned.emit(self,"initialdash")
		#If you're holding down at the end of pivot, crouch.
		elif Input.is_action_pressed(get_action("down")):
			Transitioned.emit(self,"crouch")
		#If you're not doing anything at the end of pivot, idle.
		else:
			Transitioned.emit(self,"idle")
	#You can jump cancel pivot because doesn't that sound badass?
	elif Input.is_action_pressed(get_action("jump")):
			Transitioned.emit(self, "JumpSquat")
	#Run logic as normal until pivot ends.
	else:
		character.velocity.x = lerp(character.velocity.x, 0.0, char_attributes.FRICTIONLERP)
		character.move_and_slide()
