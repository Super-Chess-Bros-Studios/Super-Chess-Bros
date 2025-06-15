extends Node

var current_state : CharacterState
# Dictionary of State objects 
var states : Dictionary = {}

enum DIRECTION {left = -1, right = 1}


#Sets the initial state
@export var initial_state : CharacterState



#_ready is called when the node is first created automatically by Godot.
#Essentially, it fills up the dictionary with each Character_State node under the
#State Machine in the scene tree.
func _ready():
	var char_attributes_class = load("res://scripts/character_scripts/state_machine/states/character_attributes.gd")
	var char_attributes = char_attributes_class.new()
	for child in get_children():
		if child is CharacterState:
			#to_lower is a precaution, of course.
			states[child.name.to_lower()] = child
			child.char_attributes = char_attributes # points to this single instance of char_attributes.
			child.Transitioned.connect(on_child_transitioned)
	#Checks if there's an initial state set in the State Machine node.
	if initial_state:
		initial_state.char_attributes.cur_dir = DIRECTION.right
		initial_state.Enter()
		current_state = initial_state
		char_attributes.cur_dir = DIRECTION.right
	else:
		push_error("There's no initial state set!")
		return

#Updates the current state chosen by the state machine.
#func _process(delta):
	#if current_state:

#Since Physics is run on a separate server or something, it also has to be updated (?)
func _physics_process(delta):
	if current_state:
		current_state.Physics_Update(delta)
		current_state.Update(delta)

func on_child_transitioned(state, new_state_name):
	# This means something went wrong.
	if state != current_state:
		return
	
	#Grab the new state from the states dictionary.
	var new_state : CharacterState = states.get(new_state_name.to_lower())
	#Make sure the new state exists.
	if !new_state:
		return
	#Check if we have a current state before we exit. 
	if current_state:
		current_state.Exit()
	
	new_state.Enter()
	
	current_state = new_state
