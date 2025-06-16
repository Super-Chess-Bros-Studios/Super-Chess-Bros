extends CharacterState
class_name TestAirDodge

@export var anim : AnimatedSprite2D
@export var character : CharacterBody2D
@export var timer : Timer

@export var speed : float = 300
var directional_input : Vector2


func playanim():
	anim.play("airdodge")
	if char_attributes.cur_dir == DIRECTION.left:
		anim.set_flip_h(true)
	else:
		anim.set_flip_h(false)

func Enter():
	print("Air dodge state")
	directional_input = Input.get_vector("left","right","up","down").normalized()
	char_attributes.invulnerable = true
	char_attributes.can_air_dodge = false
	timer.start()
	playanim()

func Exit():
	char_attributes.invulnerable = false

func Physics_Update(delta):
	if character.is_on_floor():
		Transitioned.emit(self,"idle")
	elif timer.is_stopped():
		#might add a transition to ground if grounded but i wanna see this first
		Transitioned.emit(self, "fall")
	else:
		character.velocity = directional_input * speed
		character.move_and_slide()
