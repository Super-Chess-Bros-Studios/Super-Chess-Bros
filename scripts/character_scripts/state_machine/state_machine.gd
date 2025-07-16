extends Node
class_name StateMachine

var current_state : CharacterState
# Dictionary of State objects 
var states : Dictionary = {}
enum DIRECTION {left = -1, right = 1}


#Sets the initial state and character attributes
@export var initial_state : CharacterState
@export var char_attributes : CharacterAttributes
@export var state_machine : Node
@export var hurtbox : Hurtbox

#_ready is called when the node is first created automatically by Godot.
#Essentially, it fills up the dictionary with each Character_State node under the
#State Machine in the scene tree.
func _ready():
	hurtbox.char_attributes = char_attributes
	for child in state_machine.get_children():
		if child is CharacterState:
			#to_lower is a precaution, of course.
			states[child.name.to_lower()] = child
			child.char_attributes = char_attributes # points to this single instance of char_attributes.
			child.Transitioned.connect(on_child_transitioned)
	#Checks if there's an initial state set in the State Machine node.
	if initial_state:
		initial_state.Enter()
		current_state = initial_state
		if char_attributes.player_id == 1:
			char_attributes.cur_dir = DIRECTION.right
		else:
			char_attributes.cur_dir = DIRECTION.left
	else:
		push_error("There's no initial state set!")
		return

#Updates the current state chosen by the state machine.
#func _process(delta):
	#if current_state:
		#current_state.Update(delta)

#We moved update and physics update into physics process to avoid race conditions
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

func on_hit(bkb : float, kbg : float, kb_dir : Vector2, damage : float, hitbox_group : int):
	if !char_attributes.invulnerable:
		char_attributes.just_took_damage = true
		char_attributes.bkb = bkb
		char_attributes.kbg = kbg
		char_attributes.kb_dir = kb_dir
		char_attributes.damage = damage
		char_attributes.hitbox_group = hitbox_group

func _on_roll_cooldown_timeout() -> void:
	print("roll refreshed")
	char_attributes.can_roll = true
