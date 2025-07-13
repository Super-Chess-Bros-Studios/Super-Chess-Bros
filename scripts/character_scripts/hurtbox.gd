class_name Hurtbox
extends Area2D

var char_attributes : CharacterAttributes

func _init() -> void:
	collision_layer = 1
	collision_mask = 2
	
func _ready():
	connect("area_entered", self._on_area_entered)
	
func _on_area_entered(hitbox: Hitbox) -> void:
	if hitbox == null:
		return
	#the hitbox_owner is the hurtbox
	#makes does not call the onhit if your character is invulnerable
	#nor if you just got hit by a hitbox of the same group
	elif hitbox.hitbox_owner == self or char_attributes.invulnerable or char_attributes.hitbox_group == hitbox.hitbox_group:
		return
	#passes the hitbox to the state machine script
	if owner.has_method("on_hit"):
		owner.on_hit(hitbox.bkb, hitbox.kbg, hitbox.kb_dir, hitbox.damage, hitbox.hitbox_group)
		
