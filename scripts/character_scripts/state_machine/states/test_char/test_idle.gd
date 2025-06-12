extends CharacterState
class_name TestIdle

@export var anim : AnimatedSprite2D
@export var character : CharacterBody2D
@export var friction = 0.8

enum DIRECTION {left = -1, right = 1}

func playanim():
	anim.play("idle")
	if cur_dir < 0:
		anim.set_flip_h(true)
	else:
		anim.set_flip_h(false)

func Enter():
	print("Idle state")
	playanim()

func Physics_Update(delta):
	print(cur_dir)
	if Input.is_action_pressed("left"):
		cur_dir = DIRECTION.left
		Transitioned.emit(self,"run",DIRECTION.left)
	elif Input.is_action_pressed("right"):
		cur_dir = DIRECTION.right
		Transitioned.emit(self,"run", DIRECTION.right)
	else:
		character.velocity.x -= lerp(character.velocity.x, 0.0, friction)
		character.move_and_slide()
