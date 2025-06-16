extends CharacterState
class_name TestFastFall
@export var anim : AnimatedSprite2D
@export var character : CharacterBody2D

@export var speed : float = 300

func playanim():
	anim.play("fastfall")
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
	if Input.is_action_pressed("shield") and char_attributes.can_air_dodge:
		#don't calculate move and slide until airdodge is running it's part
		Transitioned.emit(self,"airdodge")
	else:
		#if you can double jump do it if it's input
		if Input.is_action_pressed("jump") and char_attributes.can_double_jump:
			char_attributes.can_double_jump = false
			Transitioned.emit(self, "fullhop")
		
		#handles horizontal events
		elif Input.is_action_pressed("left"):
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
