extends Node
class_name CharacterAttributes


@export var player_id: int = 1  # Set this in the editor or at spawn time

const GRAVITY  : float = 10
const FASTFALLMULTIPLIER : float = 2

#These are used in the lerp functions whenever calculating physics for speed. Lerp makes it feel smoother.
const AIRSPEEDLERP : float = 0.15
const AIRFRICTIONLERP : float = 0.1
const FRICTIONLERP : float = 0.1
const MAX_FALL_SPEED : float = 600

#controls jump power
const JUMP_POWER : float = -350
const WALL_JUMP_HORIZONTAL_STRENGTH : float = 500

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
var just_took_damage = false
