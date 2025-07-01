extends CharacterState
class_name TestWallSlide

@export var slide_colliderL : Area2D
@export var slide_colliderR : Area2D

#vertical variables

#how fast you slide down a wall without holding down
@export var wall_slide_speed : float = 60

#how fast you fall while holding down during a wall slide
@export var fast_wall_slide_coefficient : float = 2
@export var max_wall_slide_speed = char_attributes.MAX_FALL_SPEED

#horizontal variables
#how fast horizontally you boost off a wall if you jump
@export var wall_jump_horizontal_strength : float = char_attributes.WALL_JUMP_HORIZONTAL_STRENGTH
#how quick you move off of a wall when inputting opposite of a wall
#this might not be too important to have
@export var wall_slide_boost = 50

var exit_wall_slide = false

func Enter():
	print("Wall Slide state")
	wall_detection_enabled(true)
	exit_wall_slide = false
	playanim("wallslide")

#this makes it so that the areas only check if you are next to a wall while falling
#that way you don't trigger the signal while on the ground
#this doesn't really matter for the MVP because you can't be on the ground and touching
#the wall on the current stage
func wall_detection_enabled(ask : bool):
	slide_colliderL.monitoring = ask
	slide_colliderR.monitoring = ask

func _on_wall_detect_body_exited(body: Node2D) -> void:
	exit_wall_slide = true
	print("wall slide exited")

func Exit():
	wall_detection_enabled(false)


func Physics_Update(delta):
	if char_attributes.just_took_damage:
		Transitioned.emit(self, "hitstun")
	#handles vertical events
	elif character.is_on_floor():
		Transitioned.emit(self, "idle")
	elif exit_wall_slide:
		Transitioned.emit(self,"fall")
	elif Input.is_action_pressed(get_action("shield")) and char_attributes.can_air_dodge:
		#don't calculate move and slide until airdodge is running it's part
		Transitioned.emit(self,"airdodge")
	elif Input.is_action_pressed(get_action("up")) and Input.is_action_pressed(get_action("special")):
		Transitioned.emit(self,"UpSpecial")
	else:
		character.velocity.y = clamp(character.velocity.y + char_attributes.GRAVITY,0,wall_slide_speed)
		#if you can wall jump do it if it's input
		if Input.is_action_pressed(get_action("jump")) and char_attributes.can_wall_jump:
			char_attributes.can_wall_jump = false
			character.velocity.x = wall_jump_horizontal_strength * char_attributes.cur_dir
			Transitioned.emit(self, "fullhop")
			
		#input for fast slide.
		elif Input.is_action_pressed(get_action("down")):
			character.velocity.y = clamp(character.velocity.y + (wall_slide_speed * fast_wall_slide_coefficient), 0, max_wall_slide_speed)
			print(character.velocity.y)
			character.move_and_slide()
			
		#handles horizontal events
		elif Input.is_action_pressed(get_action("left")):
			if char_attributes.cur_dir == DIRECTION.left:
				character.velocity.x = wall_slide_boost * char_attributes.cur_dir
				character.move_and_slide()
				Transitioned.emit(self,"fall")
			else:
				character.move_and_slide()
		elif Input.is_action_pressed(get_action("right")):
			if char_attributes.cur_dir == DIRECTION.right:
				character.velocity.x = wall_slide_boost * char_attributes.cur_dir
				character.move_and_slide()
				Transitioned.emit(self,"fall")
			else:
				character.move_and_slide()
		else:
			character.move_and_slide()
