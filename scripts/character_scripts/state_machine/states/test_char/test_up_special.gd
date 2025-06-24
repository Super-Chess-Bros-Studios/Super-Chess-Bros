extends CharacterState
class_name TestUpSpecial

@export var anim : AnimatedSprite2D
@export var character : CharacterBody2D
@export var timer : Timer

@export var speed : float = 300


func playanim():
	anim.play("up_special")
	if char_attributes.cur_dir == DIRECTION.left:
		anim.set_flip_h(true)
	else:
		anim.set_flip_h(false)

func Enter():
	print("Up Special state")
	character.velocity.y = char_attributes.JUMP_POWER
	
	timer.start()
	playanim()

func Physics_Update(delta):
	if character.is_on_floor():
		Transitioned.emit(self,"idle")
	elif timer.is_stopped():
		Transitioned.emit(self, "SpecialFall")
	
	#handles horizontal events
	elif Input.is_action_pressed(get_action("left")):
			character.velocity.x = lerp(character.velocity.x,-speed,char_attributes.AIRSPEEDLERP)
			character.move_and_slide()
	elif Input.is_action_pressed(get_action("right")):
			character.velocity.x = lerp(character.velocity.x,speed,char_attributes.AIRSPEEDLERP)
			character.move_and_slide()
	else:
		character.move_and_slide()
