extends Node

# Simple scene management signals
signal scene_changed(scene_name: String)
signal duel_ended(winner: Piece)
# Scene state
var scene_dictionary: Dictionary = {}
var current_scene_instance: Node = null
var current_scene_name: String = ""
var main: Node = null
var hud: Node = null
var level: Node2D = null
var chess_hud: Control = null


# Chess caching
var cached_chess_scene: Node = null

func initialize_scene_dictionary():
	scene_dictionary = {
		"title": preload("res://scenes/main/title_screen.tscn"),
		"main_menu": preload("res://scenes/main/main_menu.tscn"),
		"chess": preload("res://scenes/chess/chess.tscn"),
		"dual_arena": preload("res://scenes/PF/dual_arena.tscn"),
		"testScene": preload("res://scenes/PF/testScene.tscn"),
		"chess_hud": preload("res://scenes/chess/chess_hud.tscn")
	}

func set_main(main_node: Node):
	main = main_node
	if main.has_node("Hud"):
		print("Hud found")
		hud = main.get_node("Hud")
	if main.has_node("Level"):
		print("Level found")
		level = main.get_node("Level")

# Standard scene change
func change_scene(scene_name: String):
	if not scene_dictionary.has(scene_name):
		push_error("Scene not found: " + scene_name)
		return
	
	# Remove current scene
	if current_scene_instance:
		current_scene_instance.queue_free()
		current_scene_instance = null
	
	# Load new scene
	var scene_resource = scene_dictionary[scene_name]
	current_scene_instance = scene_resource.instantiate()
	level.add_child(current_scene_instance)
	current_scene_name = scene_name
	scene_changed.emit(scene_name)

func transition_to_chess():
	chess_hud = scene_dictionary["chess_hud"].instantiate()
	hud.add_child(chess_hud)
	change_scene("chess")

# Special transition to duel (caches chess)
func transition_to_duel(attacker: Piece, defender: Piece, defecit: int):

	# Cache chess scene
	cached_chess_scene = current_scene_instance
	level.remove_child(cached_chess_scene)
	current_scene_instance = null
	chess_hud.visible = false
	
	# Load duel scene
	var scene_resource = scene_dictionary["dual_arena"]
	var duel_scene = scene_resource.instantiate()
	current_scene_instance = duel_scene
	level.add_child(current_scene_instance)
	duel_scene.attacker = attacker
	duel_scene.defender = defender
	duel_scene.defecit = defecit

	current_scene_name = "dual_arena"
	scene_changed.emit("dual_arena")

# Exit duel and return to cached chess
func exit_duel(winner: Piece, looser: Piece):
	if current_scene_name != "dual_arena" or not cached_chess_scene:
		push_error("Can only exit duel when in duel scene with cached chess")
		return
	
	# Remove duel scene
	if current_scene_instance:
		current_scene_instance.queue_free()
		current_scene_instance = null
	
	# Restore chess scene
	
	current_scene_instance = cached_chess_scene
	cached_chess_scene = null
	level.add_child(current_scene_instance)
	current_scene_name = "chess"
	chess_hud.visible = true
	scene_changed.emit("chess")
	duel_ended.emit(winner, looser)

func get_current_scene() -> Node:
	return current_scene_instance

func get_current_scene_name() -> String:
	return current_scene_name

# Helper methods for common scene operations
func is_in_game_scene() -> bool:
	return current_scene_name == "chess"

func is_in_menu_scene() -> bool:
	return current_scene_name == "title_screen" 
