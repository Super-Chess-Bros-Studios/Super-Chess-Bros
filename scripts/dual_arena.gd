extends Node2D

var winner: Piece = null
var attacker: Piece = null
var defender: Piece = null
var defecit: int = 0 #brah you spelled deficit wrong


#Okay, so these will be changed later to incorporate a custom spawning system.
#I will need to create a Character Spawner scene/class that listens to this script then spawns the character, then gives
#them the properties as according to what the chess state told us.

#I could alternatively integrate that mechanic into THIS script, but it might get a little too big.
@export var TestChar1 : StateMachine
@export var TestChar2 : StateMachine

enum TEAM {white = 1, black = 0}

func _ready():
	print("Dual arena loaded!")
	if attacker.team == TEAM.white:
		TestChar1.char_attributes.player_id = TEAM.white
		TestChar2.char_attributes.player_id = TEAM.black
	else:
		TestChar1.char_attributes.player_id = TEAM.black
		TestChar2.char_attributes.player_id = TEAM.white
	print("Press cancel to choose defender as winner")
	print("Press enter to choose attacker as winner")

func _input(event):
	# Exit on cancel
	if event.is_action_pressed("ui_cancel"):
		SceneManager.exit_duel(defender, attacker) 
	if event.is_action_pressed("ui_accept"):
		SceneManager.exit_duel(attacker, defender) 
