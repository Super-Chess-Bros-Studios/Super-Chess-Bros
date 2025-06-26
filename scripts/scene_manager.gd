extends Node

# Signals for scene management
signal scene_changed(scene_name: String)
signal scene_loading_started(scene_name: String)
signal scene_loading_completed(scene_name: String)

# Scene state variables
var scene_dictionary: Dictionary = {}
var current_scene_instance: Node = null
var current_scene_name: String = ""
var canvas_layer: CanvasLayer


func initialize_scene_dictionary():
	# Register all scenes - only chess for now, plus title screen
	scene_dictionary = {
		"title_screen": preload("res://scenes/title_screen.tscn"),
		"main_menu": preload("res://scenes/main_menu.tscn")
		#"chess": preload("res://scenes/chess/board.tscn")
	}

func set_canvas_layer(layer: CanvasLayer):
	"""Called by Main to set the canvas layer to use"""
	canvas_layer = layer

func register_scene(scene_name: String, scene_resource: PackedScene):
	scene_dictionary[scene_name] = scene_resource

func has_scene(scene_name: String) -> bool:
	return scene_name in scene_dictionary and scene_dictionary[scene_name] != null

func get_scene_resource(scene_name: String) -> PackedScene:
	if has_scene(scene_name):
		return scene_dictionary[scene_name]
	return null

func change_scene(scene_name: String):
	if not has_scene(scene_name):
		push_error("Cannot change to scene '%s' - not found!" % scene_name)
		return
	
	if not canvas_layer:
		push_error("Canvas layer not set! Call set_canvas_layer() first.")
		return
	
	# Emit loading started
	scene_loading_started.emit(scene_name)
	
	# Prepare for scene change
	prepare_scene_change(scene_name)
	
	# Remove current scene
	if current_scene_instance:
		current_scene_instance.queue_free()
		current_scene_instance = null
	
	# Load new scene
	var scene_resource = scene_dictionary[scene_name]
	current_scene_instance = scene_resource.instantiate()
	canvas_layer.add_child(current_scene_instance)
	
	# Complete scene change
	complete_scene_change(scene_name)

func prepare_scene_change(new_scene_name: String):
	# Let main game manager handle any state saving
	var main_node = get_node_or_null("/root/Main")
	if main_node and main_node.has_method("prepare_for_scene_change"):
		main_node.prepare_for_scene_change(new_scene_name)

func complete_scene_change(scene_name: String):
	current_scene_name = scene_name
	scene_changed.emit(scene_name)
	scene_loading_completed.emit(scene_name)
	
	# Let main game manager handle post-scene setup
	var main_node = get_node_or_null("/root/Main")
	if main_node and main_node.has_method("handle_scene_changed"):
		main_node.handle_scene_changed.call_deferred(scene_name)

func get_current_scene() -> Node:
	return current_scene_instance

func get_current_scene_name() -> String:
	return current_scene_name

# Helper methods for common scene operations
func is_in_game_scene() -> bool:
	return current_scene_name == "chess"

func is_in_menu_scene() -> bool:
	return current_scene_name == "title_screen" 
