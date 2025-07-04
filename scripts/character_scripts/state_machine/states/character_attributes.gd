extends Node
class_name CharacterAttributes

#Export vars allow any character to use these character attributes without having to
#extend the class. You can now change any of these values in the inspector.
@export var player_id: int = 1  # Set this in the editor or at spawn time

#Used for calculating how fast a character falls.
@export var GRAVITY  : float = 10
@export var FASTFALLMULTIPLIER : float = 2

#These are used in the lerp functions whenever calculating physics for speed. Lerp makes it feel smoother.
@export var AIRSPEEDLERP : float = 0.15
@export var AIRFRICTIONLERP : float = 0.1
@export var FRICTIONLERP : float = 0.1
@export var MAX_FALL_SPEED : float = 600

#controls jump power
@export var JUMP_POWER : float = -350

#how fast horizontally you boost off a wall if you jump
@export var WALL_JUMP_HORIZONTAL_STRENGTH : float = 500

#weight is used for knockback calculations. 
@export var WEIGHT : float = 100

#These are basically "global variables" for the character that can be read and written to by other states
var cur_dir = 1

#this character can only double jump and air dodge once before needing to hit the ground
var can_double_jump = true
var can_air_dodge = true
var can_wall_jump = true
var can_recover = true
#needed for a cooldown
var can_roll = true
#hitboxes should ignore a character if they are invulnerable
var invulnerable = false
#basically the player's health
var percentage : float = 0.0

#values for when a character takes damage. should be reset back to these values when hitstun ends
var just_took_damage = false

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
var hit_on_ground : bool = false

var DI : Vector2 = Vector2.ZERO

var just_hit_enemy = false
