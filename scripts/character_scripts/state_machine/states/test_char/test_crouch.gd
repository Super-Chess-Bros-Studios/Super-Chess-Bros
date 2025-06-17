extends CharacterState
class_name TestCrouch

@export var anim : AnimatedSprite2D
@export var character : CharacterBody2D
@export var friction = 0.8

func playanim():
	anim.play("crouch")
	if char_attributes.cur_dir < 0:
		anim.set_flip_h(true)
	else:
		anim.set_flip_h(false)

func Enter():
	print("Crouch state")
	playanim()

func Physics_Update(delta):
	if !Input.is_action_pressed(controls.down):
		Transitioned.emit(self,"idle")
	else:
		character.velocity.x -= lerp(character.velocity.x, 0.0, friction)
		character.move_and_slide()
