extends Node2D

var winner: Piece = null
var attacker: Piece = null
var defender: Piece = null


func _ready():
	print("Dual arena loaded!")
	attacker = SceneManager.cached_chess_scene.game_manager.duel_attacker
	defender = SceneManager.cached_chess_scene.game_manager.duel_defender
	print("Press cancel to choose defender as winner")
	print("Press enter to choose attacker as winner")

func _input(event):
	# Exit on cancel
	if event.is_action_pressed("ui_cancel"):
		SceneManager.exit_duel(defender, attacker) 
	if event.is_action_pressed("ui_accept"):
		SceneManager.exit_duel(attacker, defender) 
