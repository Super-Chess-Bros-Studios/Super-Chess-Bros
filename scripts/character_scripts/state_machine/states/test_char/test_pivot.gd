extends CharacterState
class_name TestPivot


@export var anim : AnimatedSprite2D
@export var character : CharacterBody2D
@export var timer : Timer
#I use this timed_out variable so I don't cause a race condition
var timed_out = false

func playanim():
	anim.play("pivot")
	if char_attributes.cur_dir < 0:
		anim.set_flip_h(true)
	else:
		anim.set_flip_h(false)

func Enter():
	print("Pivot state")
	char_attributes.cur_dir *= -1
	timed_out = false
	timer.start()
	playanim()

func _on_pivot_time_timeout() -> void:
	timed_out = true

func Physics_Update(delta):
	if !character.is_on_floor():
		Transitioned.emit(self,"fall")
	
	#Every statement needs to be elif so we don't emit multiple transitioned signals.
	
	#Only allow these movements once pivot ends.
	elif timed_out:
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
