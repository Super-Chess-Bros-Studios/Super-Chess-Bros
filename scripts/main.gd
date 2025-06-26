extends Node

# Main game controller - serves as the public API hub
var game_controller: MainGameController
var input_manager: InputManager

# Child nodes
@onready var canvas_layer: CanvasLayer = $CanvasLayer

func _ready():
	initialize_systems()
	setup_connections()
	start_game()

func initialize_systems():
	game_controller = MainGameController.new()
	input_manager = InputManager.new()
	
	# Set up scene manager
	SceneManager.set_canvas_layer(canvas_layer)
	SceneManager.initialize_scene_dictionary()

func setup_connections():
	# Game controller signals
	game_controller.scene_change_requested.connect(_on_scene_change_requested)
	game_controller.game_state_changed.connect(_on_game_state_changed)
	
	# Scene manager signals (from autoload)
	SceneManager.scene_changed.connect(_on_scene_changed)
	SceneManager.scene_loading_started.connect(_on_scene_loading_started)

func start_game():
	request_scene_change("title_screen")

func request_scene_change(scene_name: String):
	game_controller.request_scene_change(scene_name)

func get_input_manager() -> InputManager:
	return input_manager

func get_game_controller() -> MainGameController:
	return game_controller

# Convenient helper for scenes to request scene changes
func change_scene(scene_name: String):
	game_controller.request_scene_change(scene_name)

func connect_scene_signals():
	var current_scene = SceneManager.get_current_scene()
	if not current_scene:
		return
	
	# Connect common scene signals if they exist
	if current_scene.has_signal("request_scene_change"):
		if not current_scene.request_scene_change.is_connected(_on_scene_change_requested):
			current_scene.request_scene_change.connect(_on_scene_change_requested)

# ==========================================
# Signal Handlers
# ==========================================

func _on_scene_change_requested(scene_name: String):
	print("Scene change requested: ", scene_name)
	SceneManager.change_scene(scene_name)

func _on_game_state_changed(new_state: MainConstants.GameState):
	print("Game state changed to: ", MainConstants.GameState.keys()[new_state])

func _on_scene_changed(scene_name: String):
	print("Scene changed to: ", scene_name)
	connect_scene_signals()

func _on_scene_loading_started(scene_name: String):
	print("Loading scene: ", scene_name)

# ==========================================
# Save/Load System
# ==========================================
