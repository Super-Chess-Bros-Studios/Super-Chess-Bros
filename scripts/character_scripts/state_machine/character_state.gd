extends Node
#This is the abstract class for all states under the character state machine.
class_name CharacterState

#This allows the State to communicate with the state machine.
signal Transitioned
var char_attributes : CharacterAttributes
enum DIRECTION {left = -1, right = 1}

@export var anim : AnimationPlayer
@export var sprite : Sprite2D
@export var character : CharacterBody2D

#automatically plays an animation and flips the sprite based on the direction the 
#direction the character is facing
func playanim(animation):
	anim.play(animation)
	if char_attributes.cur_dir < 0:
		sprite.set_flip_h(true)
	else:
		sprite.set_flip_h(false)

func freeze_frame(duration):
	Engine.time_scale = 0
	await(get_tree().create_timer(duration, true, false, true).timeout)
	Engine.time_scale = 1

#Function for entering the state
func Enter():
	pass

#Function for exiting the state
func Exit():
	pass

#Function for updating the state. 
#Delta is the time passed since the last frame. Useful for maintaining time when FPS
#is not consistent.
func Update(_delta: float):
	pass

#Same thing as above but for the physics server.
func Physics_Update(_delta: float):
	pass

func get_action(action_base: String) -> String:
	return InputManager.get_action(action_base, char_attributes.team)
