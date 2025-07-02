extends TestFall
class_name TestHitstun

@export var hitstun_length : Timer

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
	print("Hitstun state")
	begin_wall_slide = false
	#this ensures that it doesnt do any wall sliding stuff while we're in hitstun haha
	wall_detection_enabled(false)
	
	#i don't want to prefix everything with char_attributes lol
	bkb = char_attributes.bkb
	kbg = char_attributes.kbg
	kb_dir = char_attributes.kb_dir
	damage = char_attributes.damage
	hitbox_group = char_attributes.hitbox_group
	percentage = char_attributes.percentage
	
	#applies knockback
	print("knockback growth: ", kbg)
	knockback_force = (bkb + (percentage*kbg/20)) / (char_attributes.WEIGHT/100)
	print("knockback force: ", knockback_force)
	print("kb_dir before DI", kb_dir.normalized())
	kb_dir = kb_dir + char_attributes.DI
	print("kb_dir after DI", kb_dir.normalized())
	character.velocity = kb_dir.normalized() * knockback_force
	
	#hitstun length is going to take some math i'm not ready for atm
	hitstun_length.start(knockback_force/500)
	playanim("hitstun")

func Exit():
	char_attributes.hit_on_ground = false

func Physics_Update(delta):
	#if i took damage from a hitbox that isn't in the current hitbox group
	if char_attributes.just_took_damage and char_attributes.hitbox_group != hitbox_group:
		Transitioned.emit(self,"hitfreeze")
	elif hitstun_length.is_stopped():
		Transitioned.emit(self, "tumble")
	elif character.is_on_floor() and !char_attributes.hit_on_ground:
		Transitioned.emit(self,"grounded")
	else:
		#make it exist first, make it better later (tm)
		character.velocity.y = character.velocity.y + char_attributes.GRAVITY
		
		#makes it so your character still has friction when they are hit on the ground and land before
		#hitstun ends
		if char_attributes.hit_on_ground and character.is_on_floor():
			character.velocity.x = lerp(character.velocity.x, 0.0, char_attributes.FRICTIONLERP)
		character.move_and_slide()
