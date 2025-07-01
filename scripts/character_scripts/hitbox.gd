class_name Hitbox
extends Area2D

#base knockback, knockback that will be applied regardless of player's percentage
@export var bkb : float = 0
#knockback growth (basically a multiplier based on character's percentage)
@export var kbg : float = 0
#knockback direction, normalize this
@export var kb_dir : Vector2:
	set(new_kbd):
			kb_dir = new_kbd
#amount of percent the hitbox deals to the character
@export var damage : float = 0

#for damage purposes -1 will represent the character being able to be hit by any hitbox.
#hitbox groups will start at 0.
#if a character is being hit by a hitbox with a value of 0, it will have 0 as its hitbox group variable
#when another hitbox hits the player with the value of 0, it will be ignored.
#if a hitbox of value 1 hits while hitbox_group is 0, it will make contact.
@export var hitbox_group : int = -1

#makes sure that the hitbox doesn't target the owner of the hitbox
@export var hitbox_owner : Hurtbox = null

@export var flippable_sprite : FlippableSprite
var current_flip_value : bool

func _on_sprite_flipped(flip_value):
	if current_flip_value != flip_value:
		kb_dir.x *= -1
		current_flip_value = flip_value
		
		
func _init() -> void:
	collision_layer = 2
	collision_mask = 0


func _ready():
	if flippable_sprite != null:
		flippable_sprite.sprite_flipped.connect(_on_sprite_flipped)
		for child in get_children():
			flippable_sprite.sprite_flipped.connect(child._on_sprite_flipped)
