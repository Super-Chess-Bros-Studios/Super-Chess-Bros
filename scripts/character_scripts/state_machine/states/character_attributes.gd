extends Node
class_name CharacterAttributes

const GRAVITY  : float = 10
const FASTFALLMULTIPLIER : float = 2

#These are used in the lerp functions whenever calculating physics for speed. Lerp makes it feel smoother.
const AIRSPEEDLERP : float = 0.15
const AIRFRICTIONLERP : float = 0.1
const FRICTIONLERP : float = 0.1

#controls jump power
const JUMP_POWER : float = -350

#These are basically "global variables" for the character that can be read and written to by other states
var cur_dir = 1
var can_double_jump = true
