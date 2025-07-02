extends CharacterState
class_name HitFreeze

@export var hitfreeze_length : Timer

@export var hitfreeze_divisor = 3000


#DI for short. https://www.ssbwiki.com/Directional_influence
var directional_input : Vector2
#less typing
#basically the player's health
var percentage : float = 0.0
#base knockback, knockback that will be applied regardless of player's percentage
var bkb : float = 0
#knockback growth (basically a multiplier based on character's percentage)
var kbg : float = 0
#knockback direction, normalize this
var kb_dir : Vector2
#amount of percent the hitbox deals to the character
var damage : float = 0
#for damage purposes -1 will represent the character being able to be hit by any hitbox.
#hitbox groups will start at 0.
#if a character is being hit by a hitbox with a value of 0, it will have 0 as its hitbox group variable
#when another hitbox hits the player with the value of 0, it will be ignored.
#if a hitbox of value 1 hits while hitbox_group is 0, it will make contact.
var hitbox_group : int = -1
var knockback_force : float = 0

func Enter():
	print("Hitfreeze state")
	
	#basically means they don't instantly enter grounded state if they are hit on the ground
	if character.is_on_floor():
		char_attributes.hit_on_ground = true
	else:
		char_attributes.hit_on_ground = false
	
	#i don't want to prefix everything with char_attributes lol
	bkb = char_attributes.bkb
	kbg = char_attributes.kbg
	kb_dir = char_attributes.kb_dir
	damage = char_attributes.damage
	hitbox_group = char_attributes.hitbox_group
	percentage = char_attributes.percentage
	print(char_attributes.percentage, "%")
	char_attributes.percentage += char_attributes.damage
	#so you don't stay in hitstun forever
	char_attributes.just_took_damage = false
	
	knockback_force = (bkb + (percentage*kbg/20)) / char_attributes.WEIGHT
	hitfreeze_length.start(knockback_force/hitfreeze_divisor)
	print("hitfreeze length: ", knockback_force/hitfreeze_divisor)
	playanim("hitfreeze")

func Exit():
	char_attributes.DI = directional_input

func Physics_Update(delta):
	if char_attributes.just_took_damage:
		Transitioned.emit(self,"hitfreeze")
	elif hitfreeze_length.is_stopped():
		#sometimes hitfreeze is so short it literally runs on one frame
		directional_input = Input.get_vector(get_action("left"),get_action("right"),get_action("up"),get_action("down")).normalized()
		print(directional_input, ": directional input vector")
		Transitioned.emit(self,"hitstun")
	else:
		directional_input = Input.get_vector(get_action("left"),get_action("right"),get_action("up"),get_action("down")).normalized()
		print(directional_input, ": directional input vector")
