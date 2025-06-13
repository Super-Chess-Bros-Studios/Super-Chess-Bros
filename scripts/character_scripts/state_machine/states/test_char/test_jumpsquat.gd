extends CharacterState
class_name TestJumpSquat
@export var anim : AnimatedSprite2D
@export var character : CharacterBody2D
@export var friction = 0.8
@export var timer : Timer
var short_hop = false

enum DIRECTION {left = -1, right = 1}

func playanim():
	anim.play("crouch")
	if cur_dir < 0:
		anim.set_flip_h(true)
	else:
		anim.set_flip_h(false)

func Enter():
	print("Jumpsquat state")
	short_hop = false
	timer.start()
	playanim()

func _on_squat_time_timeout() -> void:
	if short_hop:
		Transitioned.emit(self, "shorthop", cur_dir)
	else:
		Transitioned.emit(self, "fullhop", cur_dir)

func Update(delta):
	if Input.is_action_just_released("ui_accept"):
		short_hop = true

func Physics_Update(delta):
	character.velocity.x -= lerp(character.velocity.x, 0.0, friction)
	character.move_and_slide()
