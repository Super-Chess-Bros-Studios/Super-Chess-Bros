extends CharacterState
class_name TestFullHop

@export var slide_colliderL : Area2D
@export var slide_colliderR : Area2D

@export var speed : float = 300
@export var double_jump_coefficient : float = 0.75

var leftCollide = false
var rightCollide = false

func Enter():
	print("Jump state")
	character.velocity.y = char_attributes.JUMP_POWER
	var leftCollide = false
	var rightCollide = false
	wall_detection_enabled(true)
	#basically this variant applies to double jump
	if !char_attributes.can_double_jump:
		character.velocity.y *= double_jump_coefficient
	playanim("jump")

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


#wall_kick_dir is kind of like cur_dir but for walls
func wall_kick(wall_kick_dir):
	char_attributes.can_wall_jump = false
	character.velocity.x = char_attributes.WALL_JUMP_HORIZONTAL_STRENGTH * wall_kick_dir
	Transitioned.emit(self, "fullhop")
		

func double_jump():
	char_attributes.can_double_jump = false
	Transitioned.emit(self, "fullhop")

func Exit():
	rightCollide = false
	leftCollide = false
	wall_detection_enabled(false)

func Physics_Update(delta):
	if char_attributes.just_took_damage:
		Transitioned.emit(self, "hitfreeze")
	#shield is prioritized here so it doesn't get overwritten by left and right inputs
	elif Input.is_action_pressed(get_action("shield")) and char_attributes.can_air_dodge:
		#don't calculate move and slide until airdodge is running it's part
		Transitioned.emit(self,"airdodge")
	
	elif Input.is_action_pressed(get_action("up")) and Input.is_action_pressed(get_action("special")):
		Transitioned.emit(self,"UpSpecial")
	
	#handles jump input
	else:
		if Input.is_action_just_pressed(get_action("jump")) and (char_attributes.can_double_jump or char_attributes.can_wall_jump):
			if char_attributes.can_wall_jump and (rightCollide or leftCollide):
				if rightCollide:
					wall_kick(DIRECTION.left)
				elif leftCollide:
					wall_kick(DIRECTION.right)
			elif char_attributes.can_double_jump:
				double_jump()
	
		#handles gravity
		elif character.velocity.y > 0:
			Transitioned.emit(self, "fall")
		else:
			character.velocity.y += char_attributes.GRAVITY

		#handles horizontal events
		if Input.is_action_pressed(get_action("left")):
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
