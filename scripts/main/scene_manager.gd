extends Node

# Simple scene management signals
signal scene_changed(scene_name: String)
signal duel_ended(winner: Piece)
# Scene state
var scene_dictionary: Dictionary = {}
var current_scene_instance: Node = null
var current_scene_name: String = ""
var canvas_layer: CanvasLayer

# Chess caching
var cached_chess_scene: Node = null

func initialize_scene_dictionary():
	scene_dictionary = {
		"title": preload("res://scenes/main/title_screen.tscn"),
		"main_menu": preload("res://scenes/main/main_menu.tscn"),
		"chess": preload("res://scenes/chess/board.tscn"),
		"dual_arena": preload("res://scenes/dual_arena.tscn"),
		"testScene": preload("res://scenes/testScene.tscn")
	}

func set_canvas_layer(layer: CanvasLayer):
	canvas_layer = layer

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
	canvas_layer.add_child(current_scene_instance)
	
	current_scene_name = scene_name
	scene_changed.emit(scene_name)

# Special transition to duel (caches chess)
func transition_to_duel():
	if current_scene_name != "chess":
		push_error("Can only transition to duel from chess scene")
		return
	
	# Cache chess scene
	cached_chess_scene = current_scene_instance
	cached_chess_scene.hide()
	current_scene_instance = null
	
	# Load duel scene
	var scene_resource = scene_dictionary["dual_arena"]
	current_scene_instance = scene_resource.instantiate()
	canvas_layer.add_child(current_scene_instance)
	
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
	current_scene_instance.show()
	current_scene_name = "chess"
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
