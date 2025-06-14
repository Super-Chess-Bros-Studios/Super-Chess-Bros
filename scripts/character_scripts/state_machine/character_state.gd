extends Node
#This is the abstract class for all states under the character state machine.
class_name CharacterState

#This allows the State to communicate with the state machine.
signal Transitioned

var char_attributes : CharacterAttributes


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
