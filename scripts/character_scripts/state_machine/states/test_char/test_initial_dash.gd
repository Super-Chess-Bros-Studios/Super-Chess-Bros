extends CharacterState
class_name TestInitialDash

# @export var anim : AnimatedSprite2D
@export var anim : AnimationPlayer
@export var speed : int = 300
@export var character : CharacterBody2D
@export var timer : Timer

func playanim():
	anim.play("run")
	if char_attributes.cur_dir == DIRECTION.left:
		anim.set_flip_h(true)
	else:
		anim.set_flip_h(false)

func Enter():
	#this is the simplest way i can think of to avoid race conditions with state 
	#switching while doing signals based on time
	print("Initial Dash State")
	timer.set_paused(false)
	timer.start()
	playanim()

func _on_dash_time_timeout() -> void:
	Transitioned.emit(self, "run")

func Physics_Update(delta):
	
	#ensures the player doesn't just run on air
	if !character.is_on_floor():
		Transitioned.emit(self,"fall")
	elif Input.is_action_just_pressed(get_action("shield")) and char_attributes.can_roll:
		Transitioned.emit(self,"roll")
	#if you let go of the key direction you're going, you transition to idle.
	elif !Input.is_action_pressed(get_action("left")) and char_attributes.cur_dir == DIRECTION.left:
		timer.set_paused(true)
		char_attributes.cur_dir = DIRECTION.left
		Transitioned.emit(self, "idle")
	elif !Input.is_action_pressed(get_action("right")) and char_attributes.cur_dir == DIRECTION.right:
		timer.set_paused(true)
		char_attributes.cur_dir = DIRECTION.right
		Transitioned.emit(self, "idle")
	#lets you jump from initial dash
	elif Input.is_action_pressed(get_action("jump")):
		timer.set_paused(true)
		Transitioned.emit(self, "jumpsquat")
	else:
		#you don't have to multiply by delta if you call move and slide for velocity
		#move and slide already handles delta.
		character.velocity.x = speed * char_attributes.cur_dir
		character.move_and_slide()
