extends CharacterState
class_name TestIdle

@export var anim : AnimatedSprite2D
@export var character : CharacterBody2D
#just so it doesnt repeat the beginning of the idle animation over and over in physics process
var idle_anim = true

func playanim(animation):
	anim.play(animation)
	if char_attributes.cur_dir < 0:
		anim.set_flip_h(true)
	else:
		anim.set_flip_h(false)

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
	
	#bunch of inputs
	if !character.is_on_floor():
		Transitioned.emit(self,"fall")
	if Input.is_action_pressed("left"):
		char_attributes.cur_dir = DIRECTION.left
		Transitioned.emit(self,"initialdash")
	elif Input.is_action_pressed("right"):
		char_attributes.cur_dir = DIRECTION.right
		Transitioned.emit(self,"initialdash")
	elif Input.is_action_pressed("down"):
		Transitioned.emit(self,"crouch")
	elif Input.is_action_pressed("jump"):
		Transitioned.emit(self, "JumpSquat")
	else:
		#if you're not moving quick enough, stop skidding
		if character.velocity.length() < 50:
			idle_anim = true
			playanim("idle")
		character.velocity.x = lerp(character.velocity.x, 0.0, char_attributes.FRICTIONLERP)
		character.move_and_slide()
