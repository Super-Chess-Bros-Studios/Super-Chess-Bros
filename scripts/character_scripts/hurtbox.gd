class_name Hurtbox
extends Area2D

var char_attributes

func _init() -> void:
	collision_layer = 0
	collision_mask = 2
	
func _ready():
	connect("area_entered", self._on_area_entered)
	
func _on_area_entered(hitbox: Hitbox) -> void:
	if hitbox == null:
		return
	elif hitbox.hitbox_owner == self:
		return
	#passes the hitbox to the state machine script
	if owner.has_method("on_hit"):
		owner.on_hit(hitbox.bkb, hitbox.kbg, hitbox.kb_dir, hitbox.damage, hitbox.hitbox_group)
		
	
