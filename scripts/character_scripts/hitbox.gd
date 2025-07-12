class_name Hitbox
extends Area2D

#base knockback, knockback that will be applied regardless of player's percentage
@export var bkb : float = 0
#knockback growth (basically a multiplier based on character's percentage)
@export var kbg : float = 0
#knockback direction, normalize this
@export var kb_dir : Vector2
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

@export var char_attributes : CharacterAttributes
@export var collision_box : CollisionShape2D

var default_kb_dir
var default_collision_offset

func _init() -> void:
	collision_layer = 2
	collision_mask = 1

func _ready():
	area_entered.connect(on_area_entered)


#this is primarily used to trigger hitfreeze on the person attacking
#as of now, hitfreeze on the person attacking freezes the entire game engine
#hitfreeze on the person being hit are additional frames on top of the game engine being frozen
func on_area_entered(hurtbox) -> void:
	if hurtbox is not Hurtbox:
		return
	#prevents hitboxes from detecting their owner
	if hurtbox == hitbox_owner:
		return
	#needs to check if the hitbox belongs to a character
	if char_attributes:
		char_attributes.just_hit_enemy = true
		print("just hit enemy")

func default_hitbox():
	default_collision_offset = collision_box.position.x
	default_kb_dir = kb_dir
	print("default collision offset: ", default_collision_offset)
	print("default kb dir: ", default_kb_dir)
	collision_box.disabled = true

func activate_hitbox():
	default_collision_offset = collision_box.position.x
	kb_dir.x *= char_attributes.cur_dir
	print(kb_dir, ": kb dir")
	collision_box.position.x *= char_attributes.cur_dir
	print(collision_box.position.x, ": collision offset")
	collision_box.disabled = false

func deactivate_hitbox():
	#needs to be flipped back around
	kb_dir = default_kb_dir
	collision_box.position.x = default_collision_offset
	collision_box.disabled = true
