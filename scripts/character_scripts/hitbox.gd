class_name Hitbox
extends Area2D

var kbg # knock back growth
var bkb # base knock back
var kbd # knock back direction
var damage

func _init() -> void:
	collision_layer = 2
	collision_mask = 0
 
