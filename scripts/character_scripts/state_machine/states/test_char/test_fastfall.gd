extends TestFall
class_name TestFastFall

func Enter():
	print("FastFall state")
	begin_wall_slide = false
	wall_detection_enabled(true)
	character.velocity.y = char_attributes.MAX_FALL_SPEED
	playanim("fastfall")

#this makes it so that the areas only check if you are next to a wall while falling
#that way you don't trigger the signal while on the ground
#this doesn't really matter for the MVP because you can't be on the ground and touching
#the wall on the current stage
func wall_detection_enabled(ask : bool):
	slide_colliderL.monitoring = ask
	slide_colliderR.monitoring = ask

func _on_left_collide(body: Node2D) -> void:
	begin_wall_slide = true
	print("wall collide on left")
	char_attributes.cur_dir = DIRECTION.right

func _on_right_collide(body: Node2D) -> void:
	begin_wall_slide = true
	print("wall collide on right")
	char_attributes.cur_dir = DIRECTION.left

func Physics_Update(delta):
	if char_attributes.just_took_damage:
		Transitioned.emit(self, "hitfreeze")
	#handles vertical events
	elif character.is_on_floor():
		Transitioned.emit(self, "idle")
	elif Input.is_action_pressed(get_action("shield")) and char_attributes.can_air_dodge:
		#don't calculate move and slide until airdodge is running it's part
		Transitioned.emit(self,"airdodge")
	elif Input.is_action_pressed(get_action("up")) and Input.is_action_pressed(get_action("special")):
		Transitioned.emit(self,"UpSpecial")
	elif begin_wall_slide:
		Transitioned.emit(self,"wallslide")

	else:
		character.velocity.y = clamp(character.velocity.y + char_attributes.GRAVITY * char_attributes.FASTFALLMULTIPLIER, 0, char_attributes.MAX_FALL_SPEED)
		#if you can double jump do it if it's input
		if Input.is_action_pressed(get_action("jump")) and char_attributes.can_double_jump:
			char_attributes.can_double_jump = false
			Transitioned.emit(self, "fullhop")
		
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
