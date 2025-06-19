extends CharacterState
class_name TestFall

@export var anim : AnimatedSprite2D
@export var character : CharacterBody2D

@export var speed : float = 300
@export var slide_colliderL : Area2D
@export var slide_colliderR : Area2D
var begin_wall_slide = false

func playanim():
	anim.play("fall")
	if char_attributes.cur_dir == DIRECTION.left:
		anim.set_flip_h(true)
	else:
		anim.set_flip_h(false)

func Enter():
	print("Fall state")
	begin_wall_slide = false
	wall_detection_enabled(true)
	playanim()

#this makes it so that the areas only check if you are next to a wall while falling
#that way you don't trigger the signal while on the ground
#this doesn't really matter for the MVP because you can't be on the ground and touching
#the wall on the current stage
func wall_detection_enabled(ask : bool):
	slide_colliderL.monitoring = ask
	slide_colliderR.monitoring = ask

#transitions to wall slide and sets the direction to opposite of the wall when a wall is touched
func _on_left_collide(body: Node2D) -> void:
	begin_wall_slide = true
	print("wall slide begun")
	char_attributes.cur_dir = DIRECTION.right

func _on_right_collide(body: Node2D) -> void:
	begin_wall_slide = true
	print("wall slide begun")
	char_attributes.cur_dir = DIRECTION.left


func Exit():
	begin_wall_slide = false
	wall_detection_enabled(false)

func Physics_Update(delta):
	#handles vertical events
	if character.is_on_floor():
		Transitioned.emit(self, "idle")
	elif Input.is_action_pressed("shield") and char_attributes.can_air_dodge:
		#don't calculate move and slide until airdodge is running it's part
		Transitioned.emit(self,"airdodge")
	elif begin_wall_slide:
		Transitioned.emit(self,"wallslide")
		
	else:
		character.velocity.y = clamp(character.velocity.y + char_attributes.GRAVITY, -char_attributes.MAX_FALL_SPEED, char_attributes.MAX_FALL_SPEED)
		#if you can double jump do it if it's input
		if Input.is_action_pressed("jump") and char_attributes.can_double_jump:
			char_attributes.can_double_jump = false
			Transitioned.emit(self, "fullhop")
			
		#input for fastfall.
		elif Input.is_action_pressed("down"):
			Transitioned.emit(self, "fastfall")
			
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
