extends Node2D

var winner: Piece = null
var attacker: Piece = null
var defender: Piece = null


func _ready():
	print("Dual arena loaded!")
	attacker = SceneManager.cached_chess_scene.game_manager.duel_attacker
	defender = SceneManager.cached_chess_scene.game_manager.duel_defender
	
	# Create a simple UI for testing
	var label = Label.new()
	label.text = "DUAL ARENA - Press ESC to return to chess"
	label.position = Vector2(100, 100)
	add_child(label)

func _input(event):
	# Exit on cancel
	if event.is_action_pressed("ui_cancel"):
		SceneManager.exit_duel(defender) 
