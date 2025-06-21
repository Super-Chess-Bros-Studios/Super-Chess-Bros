extends CharacterState
class_name TestRun

@export var anim : AnimatedSprite2D
@export var speed : int = 400
@export var character : CharacterBody2D
@export var timer : Timer
#I use this timed_out variable so I don't cause a race condition
var timed_out = false

func playanim(animation):
	anim.play(animation)
	if char_attributes.cur_dir == DIRECTION.left:
		anim.set_flip_h(true)
	else:
		anim.set_flip_h(false)

func Enter():
	print("Run state")
	#just in case
	timed_out = false
	playanim("run")

func _on_pre_transition_timeout() -> void:
	print("timed out")
	timed_out = true

#applies friction and starts a physics update on the character.
#remember that every time you finish everything on a given frame you have to apply move and slide.
func apply_friction():
	character.velocity.x = lerp(character.velocity.x, 0.0, char_attributes.FRICTIONLERP)
	character.move_and_slide()

func Physics_Update(delta):

	#ensures the player doesn't just run on air
	if !character.is_on_floor():
		Transitioned.emit(self,"fall")
	#This handles transition to pivot
	elif !timer.is_stopped() and Input.is_action_pressed(get_action("right")) and char_attributes.cur_dir == DIRECTION.left:
		Transitioned.emit(self, "Pivot")
	elif !timer.is_stopped() and Input.is_action_pressed(get_action("left")) and char_attributes.cur_dir == DIRECTION.right:
		Transitioned.emit(self, "Pivot")
	
	#handles transition to roll
	elif Input.is_action_just_pressed(get_action("shield")) and char_attributes.can_roll:
		Transitioned.emit(self,"roll")
	
	#if you let go of the key direction you're going, you transition to idle.
	elif !Input.is_action_pressed(get_action("left")) and char_attributes.cur_dir == DIRECTION.left:
		
		#I have to add !timed_out because it'll trigger twice otherwise.
		if timer.is_stopped() and !timed_out:
			timer.start()
			#Starts a skidding animation, since you let go.
			playanim("skid")
			#apply_friction()
		elif timed_out:
			#apply_friction()
			Transitioned.emit(self, "idle")
	elif !Input.is_action_pressed(get_action("right")) and char_attributes.cur_dir == DIRECTION.right:
		if timer.is_stopped() and !timed_out:
			timer.start()
			playanim("skid")
			#apply_friction()
		elif timed_out:
			#apply_friction()
			Transitioned.emit(self, "idle")
	
	elif Input.is_action_pressed(get_action("down")):
		Transitioned.emit(self,"crouch")
	
	#This handles transition to jumpsquat
	elif Input.is_action_pressed(get_action("jump")):
		Transitioned.emit(self, "JumpSquat")


	
	#Otherwise just stay in this state and run
	else:
		#you don't have to multiply by delta if you call move and slide for velocity
		#move and slide already handles delta.
		character.velocity.x = speed * char_attributes.cur_dir
		character.move_and_slide()
