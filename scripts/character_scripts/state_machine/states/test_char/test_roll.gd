extends CharacterState
class_name TestRoll

#starts a cooldown for the roll
@export var roll_cooldown_timer : Timer

var is_roll_end = false
@export var speed : float = 300
var directional_input : Vector2

func Enter():
	print("Roll state")
	is_roll_end = false
	directional_input = Input.get_vector(get_action("left"),get_action("right"),get_action("up"),get_action("down"))
	#maintains the input as a vector, allows you to separate cur_dir from the actual input
	directional_input.y = 0
	directional_input = directional_input.normalized()
	char_attributes.invulnerable = true
	playanim("roll")

func end_roll():
	is_roll_end = true

func Exit():
	char_attributes.invulnerable = false
	char_attributes.can_roll = false
	roll_cooldown_timer.start()

func Physics_Update(delta):
	if !character.is_on_floor():
		Transitioned.emit(self,"fall")
	elif is_roll_end:
		#might add a transition to ground if grounded but i wanna see this first
		Transitioned.emit(self, "idle")
	else:
		character.velocity = directional_input * speed
		character.move_and_slide()
