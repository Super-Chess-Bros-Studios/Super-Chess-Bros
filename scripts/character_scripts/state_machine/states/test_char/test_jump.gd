extends CharacterState
class_name TestFullHop

@export var anim : AnimatedSprite2D
@export var character : CharacterBody2D

@export var speed : float = 300
@export var jump_power : float = -350

#these control how quick they change velocity in the air
@export var friction = 0.8
@export var air_interpolation = 0.4

func playanim():
	anim.play("jump")
	if char_attributes.cur_dir == DIRECTION.left:
		anim.set_flip_h(true)
	else:
		anim.set_flip_h(false)

func Enter():
	print("Jump state")
	character.velocity.y = jump_power
	playanim()

func Physics_Update(delta):
	#handles vertical events
	
	#i commented is on floor out here because it would transition to idle for a frame on every jump
	#if character.is_on_floor():
		#Transitioned.emit(self, "idle", char_attributes.cur_dir)
	if character.velocity.y > 0:
		Transitioned.emit(self, "fall")
	else:
		character.velocity.y += char_attributes.GRAVITY
	
	#handles horizontal events
	if Input.is_action_pressed("left"):
		character.velocity.x = lerp(character.velocity.x,-speed,air_interpolation)
		character.move_and_slide()
	elif Input.is_action_pressed("right"):
		character.velocity.x = lerp(character.velocity.x,speed,air_interpolation)
		character.move_and_slide()
	else:
		#you don't have to multiply by delta if you call move and slide for velocity
		#move and slide already handles delta.
		character.velocity.x = lerp(character.velocity.x, 0.0, friction)
		character.move_and_slide()
