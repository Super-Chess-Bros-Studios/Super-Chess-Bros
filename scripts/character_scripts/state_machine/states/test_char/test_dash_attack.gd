extends CharacterState
class_name TestDashAttack

#every hitbox needs to be manually deactivated if the dash attack ends early
#maybe someone could find a solution to this at some point, we'd need to talk! - carlos
@export var da_hitbox1 : Hitbox
@export var da_hitbox2 : Hitbox

@export var speed : float = 400
var dash_attack_ended = false

func Enter():
	print("Dash Attack State")
	dash_attack_ended = false
	da_hitbox1.default_hitbox()
	da_hitbox2.default_hitbox()
	playanim("dash_attack")

func end_of_dash_attack():
	dash_attack_ended = true

func Exit():
	da_hitbox1.deactivate_hitbox()
	da_hitbox2.deactivate_hitbox()

func Physics_Update(_delta: float):
	if char_attributes.just_took_damage:
		#Any time an attack has hitboxes, the hitboxes need to be deactivated before the state transitions.
		#Don't worry, you still have functionality like rapid jabs available by just looping the animation!
		Transitioned.emit(self,"hitfreeze")
	elif char_attributes.just_hit_enemy:
		freeze_frame(0.1)
		char_attributes.just_hit_enemy = false
	elif !character.is_on_floor():
		Transitioned.emit(self,"fall")
	elif dash_attack_ended:
		Transitioned.emit(self, "idle")
	else:
		character.velocity.x = speed * char_attributes.cur_dir
		character.move_and_slide()
