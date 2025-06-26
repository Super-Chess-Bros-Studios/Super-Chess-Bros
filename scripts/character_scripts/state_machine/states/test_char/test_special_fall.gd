extends TestFall
class_name TestSpecialFall

@export var double_jump_coefficient : float = 0.75
@export var wall_jump_horizontal_strength : float = char_attributes.WALL_JUMP_HORIZONTAL_STRENGTH

var leftCollide = false
var rightCollide = false

func Enter():
	print("Special Fall state")
	var leftCollide = false
	var rightCollide = false
	wall_detection_enabled(true)
	playanim("special_fall")

#this entire section of code is for the wall kick you can do while rising in the air

func wall_detection_enabled(ask : bool):
	slide_colliderL.monitoring = ask
	slide_colliderR.monitoring = ask

func _on_left_collide(body: Node2D) -> void:
	leftCollide = true

func _on_right_collide(body: Node2D) -> void:
	rightCollide = true

func _on_left_collide_body_exited(body: Node2D) -> void:
	leftCollide = false

func _on_right_collide_body_exited(body: Node2D) -> void:
	rightCollide = false

func applyGravity():
	character.velocity.y = clamp(character.velocity.y + char_attributes.GRAVITY, -char_attributes.MAX_FALL_SPEED, char_attributes.MAX_FALL_SPEED)

#wall_kick_dir is kind of like cur_dir but for walls
func wall_kick(wall_kick_dir):
	char_attributes.can_wall_jump = false
	character.velocity.x = wall_jump_horizontal_strength * wall_kick_dir
	Transitioned.emit(self, "fullhop")

func Physics_Update(delta):
	print("can wall jump:", char_attributes.can_wall_jump)
	#handles vertical events
	if character.is_on_floor():
		Transitioned.emit(self, "idle")
	
	elif Input.is_action_just_pressed(get_action("jump")) and char_attributes.can_wall_jump:
		if rightCollide or leftCollide:
			if rightCollide:
				print("wallkick")
				wall_kick(DIRECTION.left)
			elif leftCollide:
				print("wallkick")
				wall_kick(DIRECTION.right)
			else:
				applyGravity()
				character.move_and_slide()
		else:
			applyGravity()
			character.move_and_slide()
	
	else:
		applyGravity()
		
		#input for fastfall.
		if Input.is_action_pressed(get_action("down")) and character.velocity.y > 0:
			character.velocity.y = char_attributes.MAX_FALL_SPEED
			character.move_and_slide()
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
