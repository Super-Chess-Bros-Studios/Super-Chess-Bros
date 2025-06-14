extends CharacterState
class_name TestRun

@export var anim : AnimatedSprite2D
@export var speed : int = 300
@export var character : CharacterBody2D

enum DIRECTION {left = -1, right = 1}

func playanim():
	anim.play("run")
	if char_attributes.cur_dir == DIRECTION.left:
		anim.set_flip_h(true)
	else:
		anim.set_flip_h(false)

func Enter():
	print("Run state")
	playanim()

func Physics_Update(delta):
	#if you let go of the key direction you're going, you transition to idle.
	if !Input.is_action_pressed("left") and char_attributes.cur_dir == DIRECTION.left:
		char_attributes.cur_dir = DIRECTION.left
		Transitioned.emit(self, "idle", char_attributes)
	elif !Input.is_action_pressed("right") and char_attributes.cur_dir == DIRECTION.right:
		Transitioned.emit(self, "idle", char_attributes)
	elif Input.is_action_pressed("ui_accept"):
		Transitioned.emit(self, "JumpSquat", char_attributes)
	else:
		#you don't have to multiply by delta if you call move and slide for velocity
		#move and slide already handles delta.
		character.velocity.x = speed * char_attributes.cur_dir
		character.move_and_slide()
