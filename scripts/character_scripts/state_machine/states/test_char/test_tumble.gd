extends TestFall
class_name TestTumble

#https://www.ssbwiki.com/Tumbling

func Enter():
	playanim("tumble")
	char_attributes.bkb = 0
	char_attributes.kbg = 0
	char_attributes.kb_dir = Vector2.ZERO
	char_attributes.damage = 0
	char_attributes.hitbox_group = -1

func Physics_Update(delta):
	if char_attributes.just_took_damage:
		Transitioned.emit(self, "hitfreeze")
	#handles vertical events
	elif character.is_on_floor():
		char_attributes.landing_lag_length = 0.4
		Transitioned.emit(self, "grounded")
	elif Input.is_action_pressed(get_action("shield")) and char_attributes.can_air_dodge:
		#don't calculate move and slide until airdodge is running it's part
		Transitioned.emit(self,"airdodge")
	elif Input.is_action_pressed(get_action("up")) and Input.is_action_pressed(get_action("special")):
		Transitioned.emit(self,"UpSpecial")
	#removing the ability to wall slide from tumble when compared to fall
	#elif begin_wall_slide and (char_attributes.can_air_dodge or char_attributes.can_double_jump or char_attributes.can_wall_jump):
		#Transitioned.emit(self,"wallslide")
		
	else:
		character.velocity.y = clamp(character.velocity.y + char_attributes.GRAVITY, -char_attributes.MAX_FALL_SPEED, char_attributes.MAX_FALL_SPEED)
		#if you can double jump do it if it's input
		if Input.is_action_pressed(get_action("jump")) and char_attributes.can_double_jump:
			char_attributes.can_double_jump = false
			Transitioned.emit(self, "fullhop")
		
		#removed the ability to fastfall out of tumble.
		#input for fastfall.
		#elif Input.is_action_pressed(get_action("down")):
			#Transitioned.emit(self, "fastfall")
			
		#handles horizontal events
		elif Input.is_action_pressed(get_action("left")):
			character.velocity.x = lerp(character.velocity.x,-speed,char_attributes.AIRSPEEDLERP)
			character.move_and_slide()
		elif Input.is_action_pressed(get_action("right")):
			character.velocity.x = lerp(character.velocity.x,speed,char_attributes.AIRSPEEDLERP)
			character.move_and_slide()
		else:
			#you don't have to multiply by delta if you call move and slide for velocity
			#move and slide already handles delta.
			character.velocity.x = lerp(character.velocity.x, 0.0, char_attributes.AIRFRICTIONLERP)
			character.move_and_slide()
