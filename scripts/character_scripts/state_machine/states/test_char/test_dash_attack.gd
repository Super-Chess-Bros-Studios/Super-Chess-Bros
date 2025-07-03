extends CharacterState
class_name TestDashAttack

@export var da_hitbox : Hitbox
@export var speed : float = 400
var dash_attack_ended = false

func Enter():
	print("Dash Attack State")
	dash_attack_ended = false
	playanim("dash_attack")

func end_of_dash_attack():
	dash_attack_ended = true

func Physics_Update(_delta: float):
	if char_attributes.just_took_damage:
		da_hitbox.deactivate_hitbox()
		Transitioned.emit(self,"hitfreeze")
	elif char_attributes.just_hit_enemy:
		freeze_frame(0.1)
		char_attributes.just_hit_enemy = false
	elif !character.is_on_floor():
		da_hitbox.deactivate_hitbox()
		Transitioned.emit(self,"fall")
	elif dash_attack_ended:
		Transitioned.emit(self, "idle")
	else:
		character.velocity.x = speed * char_attributes.cur_dir
		character.move_and_slide()
