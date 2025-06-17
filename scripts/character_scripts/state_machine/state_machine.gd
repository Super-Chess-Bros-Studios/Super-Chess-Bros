extends Node

@export var device_id: int
var input : DeviceInput
var current_state : CharacterState

# Dictionary of State objects 
var states : Dictionary = {}

enum DIRECTION {left = -1, right = 1}


#Sets the initial state
@export var initial_state : CharacterState


func _ready():
	# Delay initialization until joypad is ready
	var devices = Input.get_connected_joypads()
	print(devices)
	print("Expected device_id: ", device_id)

	# If the device is already connected and actions are ready
	if MultiplayerInput.device_actions.has(device_id):
		_init_device_input()
	else:
		# Wait until device connects and its actions are created
		Input.joy_connection_changed.connect(_on_joy_connection_changed)


#_ready is called when the node is first created automatically by Godot.
#Essentially, it fills up the dictionary with each Character_State node under the
#State Machine in the scene tree.
func _init_device_input():
	input = DeviceInput.new(device_id)
	var char_attributes_class = load("res://scripts/character_scripts/state_machine/states/character_attributes.gd")
	var char_attributes = char_attributes_class.new()

	for child in get_children():
		if child is CharacterState:
			states[child.name.to_lower()] = child
			child.char_attributes = char_attributes
			child.input = input
			child.Transitioned.connect(on_child_transitioned)

	if initial_state:
		initial_state.char_attributes.cur_dir = DIRECTION.right
		initial_state.Enter()
		current_state = initial_state
		char_attributes.cur_dir = DIRECTION.right
	else:
		push_error("There's no initial state set!")
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
	

func _on_joy_connection_changed(device: int, connected: bool):
	if device == device_id and connected:
		# Make sure actions are initialized
		if MultiplayerInput.device_actions.has(device):
			_init_device_input()
		else:
			await get_tree().create_timer(0.1).timeout  # Delay a bit, let MultiplayerInput catch up
			if MultiplayerInput.device_actions.has(device):
				_init_device_input()
