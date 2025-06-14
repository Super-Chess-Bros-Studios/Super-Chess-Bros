extends CharacterState
class_name TestIdle

@export var anim : AnimatedSprite2D
@export var character : CharacterBody2D
@export var friction = 0.8

enum DIRECTION {left = -1, right = 1}

func playanim():
	anim.play("idle")
	if char_attributes.cur_dir < 0:
		anim.set_flip_h(true)
	else:
		anim.set_flip_h(false)

func Enter():
	print("Idle state")
	playanim()

func Physics_Update(delta):
	if !character.is_on_floor():
		Transitioned.emit(self,"fall", char_attributes)
	if Input.is_action_pressed("left"):
		char_attributes.cur_dir = DIRECTION.left
		Transitioned.emit(self,"initialdash",char_attributes)
	elif Input.is_action_pressed("right"):
		char_attributes.cur_dir = DIRECTION.right
		Transitioned.emit(self,"initialdash", char_attributes)
	elif Input.is_action_pressed("down"):
		Transitioned.emit(self,"crouch", char_attributes)
	elif Input.is_action_pressed("ui_accept"):
		Transitioned.emit(self, "JumpSquat", char_attributes)
	else:
		character.velocity.x -= lerp(character.velocity.x, 0.0, friction)
		character.move_and_slide()
