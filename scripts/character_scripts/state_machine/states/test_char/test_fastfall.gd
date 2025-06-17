extends CharacterState
class_name TestFastFall
@export var anim : AnimatedSprite2D
@export var character : CharacterBody2D

@export var speed : float = 300
@export var jump_power : float = -500

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
	print("FastFall state")
	character.velocity.y += 200
	playanim()

func Physics_Update(delta):
	#handles vertical events
	if character.is_on_floor():
		Transitioned.emit(self, "idle")
	else:
		character.velocity.y += char_attributes.GRAVITY * char_attributes.FASTFALLMULTIPLIER
	
	#handles horizontal events
	if input.is_action_pressed("left"):
		character.velocity.x = lerp(character.velocity.x,-speed,air_interpolation)
		character.move_and_slide()
	elif input.is_action_pressed("right"):
		character.velocity.x = lerp(character.velocity.x,speed,air_interpolation)
		character.move_and_slide()
	else:
		#you don't have to multiply by delta if you call move and slide for velocity
		#move and slide already handles delta.
		character.velocity.x = lerp(character.velocity.x, 0.0, friction)
		character.move_and_slide()
