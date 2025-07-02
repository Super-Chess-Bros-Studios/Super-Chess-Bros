extends CharacterState
class_name TestInitialDash

# @export var anim : AnimatedSprite2D
@export var speed : float = 300

var initial_dash_ended = false

func Enter():
	#this is the simplest way i can think of to avoid race conditions with state 
	#switching while doing signals based on time
	print("Initial Dash State")
	initial_dash_ended = false
	playanim("initial_dash")

func end_initial_dash():
	print("ended initial dash")
	initial_dash_ended = true

func Physics_Update(delta):
	
	if char_attributes.just_took_damage:
		Transitioned.emit(self, "hitstun")
	#ensures the player doesn't just run on air
	elif !character.is_on_floor():
		Transitioned.emit(self,"fall")
	elif initial_dash_ended:
		Transitioned.emit(self, "run")
	elif Input.is_action_just_pressed(get_action("shield")) and char_attributes.can_roll:
		Transitioned.emit(self,"roll")
	#if you let go of the key direction you're going, you transition to idle.
	elif !Input.is_action_pressed(get_action("left")) and char_attributes.cur_dir == DIRECTION.left:
		char_attributes.cur_dir = DIRECTION.left
		Transitioned.emit(self, "idle")
	elif !Input.is_action_pressed(get_action("right")) and char_attributes.cur_dir == DIRECTION.right:
		char_attributes.cur_dir = DIRECTION.right
		Transitioned.emit(self, "idle")
	#lets you jump from initial dash
	elif Input.is_action_pressed(get_action("jump")):
		Transitioned.emit(self, "jumpsquat")
	else:
		#you don't have to multiply by delta if you call move and slide for velocity
		#move and slide already handles delta.
		character.velocity.x = speed * char_attributes.cur_dir
		character.move_and_slide()
