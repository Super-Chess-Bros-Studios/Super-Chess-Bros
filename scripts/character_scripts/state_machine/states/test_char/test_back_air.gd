extends CharacterState
class_name TestBackAir

@export var hitbox : Hitbox
@export var speed : float = 300
var fastfall = false
var end_of_bair = false

func Enter():
	char_attributes.cur_dir *= -1
	fastfall = false
	end_of_bair = false
	playanim("back_air")

func Exit():
	hitbox.deactivate_hitbox()

func end_bair():
	end_of_bair = true

func Update(delta):
	if char_attributes.just_took_damage:
		Transitioned.emit(self, "hitfreeze")
	#handles vertical events
	elif end_of_bair:
		Transitioned.emit(self,"fall")
	elif character.is_on_floor():
		char_attributes.landing_lag_length = 0.4
		Transitioned.emit(self, "grounded")
		
	#input for fastfall.
	elif Input.is_action_pressed(get_action("down")) and character.velocity.y > 0:
		fastfall = true
		character.velocity.x = lerp(character.velocity.x, 0.0, char_attributes.AIRFRICTIONLERP)
		character.velocity.y = char_attributes.MAX_FALL_SPEED
		character.move_and_slide()
	#handles horizontal events
	elif Input.is_action_pressed(get_action("left")):
		character.velocity.x = lerp(character.velocity.x,-speed,char_attributes.AIRSPEEDLERP)
		character.velocity.y = clamp(character.velocity.y + char_attributes.GRAVITY, -char_attributes.MAX_FALL_SPEED, char_attributes.MAX_FALL_SPEED)
		character.move_and_slide()
	elif Input.is_action_pressed(get_action("right")):
		character.velocity.x = lerp(character.velocity.x,speed,char_attributes.AIRSPEEDLERP)
		character.velocity.y = clamp(character.velocity.y + char_attributes.GRAVITY, -char_attributes.MAX_FALL_SPEED, char_attributes.MAX_FALL_SPEED)
		character.move_and_slide()
	else:
		#you don't have to multiply by delta if you call move and slide for velocity
		#move and slide already handles delta.
		character.velocity.x = lerp(character.velocity.x, 0.0, char_attributes.AIRFRICTIONLERP)
		character.velocity.y = clamp(character.velocity.y + char_attributes.GRAVITY, -char_attributes.MAX_FALL_SPEED, char_attributes.MAX_FALL_SPEED)
		if fastfall:
			character.velocity.y = char_attributes.MAX_FALL_SPEED
		character.move_and_slide()
