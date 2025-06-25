extends CharacterState
class_name TestCrouch

# @export var anim : AnimatedSprite2D
@export var anim : AnimationPlayer
@export var character : CharacterBody2D

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
	if !character.is_on_floor():
		Transitioned.emit(self,"fall")
	elif !Input.is_action_pressed(get_action("down")):
		Transitioned.emit(self,"idle")
	elif Input.is_action_pressed(get_action("jump")):
		Transitioned.emit(self, "jumpsquat")
	else:
		character.velocity.x -= lerp(character.velocity.x, 0.0, char_attributes.FRICTIONLERP)
		character.move_and_slide()
