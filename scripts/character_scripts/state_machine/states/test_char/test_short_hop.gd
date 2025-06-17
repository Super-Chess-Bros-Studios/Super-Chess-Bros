extends CharacterState
class_name TestShortHop

@export var anim : AnimatedSprite2D
@export var character : CharacterBody2D

@export var speed : float = 300
@export var jump_power_coefficient = 0.5

func playanim():
	anim.play("jump")
	if char_attributes.cur_dir == DIRECTION.left:
		anim.set_flip_h(true)
	else:
		anim.set_flip_h(false)

func Enter():
	print("Short hop state")
	character.velocity.y = char_attributes.JUMP_POWER * jump_power_coefficient
	playanim()

func Physics_Update(delta):
	#handles vertical events
	
	#i commented is on floor out here because it would transition to idle for a frame on every jump
	#if character.is_on_floor():
		#Transitioned.emit(self, "idle", cur_dir)
	if Input.is_action_just_pressed("jump") and char_attributes.can_double_jump:
		char_attributes.can_double_jump = false
		character.velocity.y = char_attributes.JUMP_POWER
	elif character.velocity.y > 0:
		Transitioned.emit(self, "fall")
	else:
		character.velocity.y += char_attributes.GRAVITY
	
	#handles horizontal events
	if Input.is_action_pressed("left"):
		character.velocity.x = lerp(character.velocity.x,-speed,char_attributes.AIRSPEEDLERP)
		character.move_and_slide()
	elif Input.is_action_pressed("right"):
		character.velocity.x = lerp(character.velocity.x,speed,char_attributes.AIRSPEEDLERP)
		character.move_and_slide()
	else:
		#you don't have to multiply by delta if you call move and slide for velocity
		#move and slide already handles delta.
		character.velocity.x = lerp(character.velocity.x, 0.0, char_attributes.AIRFRICTIONLERP)
		character.move_and_slide()
