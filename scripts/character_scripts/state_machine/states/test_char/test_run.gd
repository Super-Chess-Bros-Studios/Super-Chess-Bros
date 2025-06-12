extends CharacterState
class_name TestRun

@export var anim : AnimatedSprite2D
@export var speed : int = 300
@export var character : CharacterBody2D

enum DIRECTION {left = -1, right = 1}

func playanim():
	anim.play("run")
	print("Run state")
	if cur_dir == DIRECTION.left:
		anim.set_flip_h(true)
	else:
		anim.set_flip_h(false)

func Enter():
	playanim()

func Physics_Update(delta):
	#if you let go of the key direction you're going, you transition to idle.
	if !Input.is_action_pressed("left") and cur_dir == DIRECTION.left:
		Transitioned.emit(self, "idle", DIRECTION.left)
	elif !Input.is_action_pressed("right") and cur_dir == DIRECTION.right:
		Transitioned.emit(self, "idle", DIRECTION.right)
	else:
		#you don't have to multiply by delta if you call move and slide for velocity
		#move and slide already handles delta.
		character.velocity.x = speed * cur_dir
		character.move_and_slide()
