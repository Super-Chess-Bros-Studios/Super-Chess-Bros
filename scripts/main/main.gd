extends Node

# Core systems
var game_controller: MainGameController

@onready var canvas_layer: CanvasLayer = $CanvasLayer

func _ready():
	initialize_systems()
	setup_connections()
	start_game()

func initialize_systems():
	# Create controllers
	game_controller = MainGameController.new()
	
	canvas_layer.follow_viewport_enabled = true
	canvas_layer.layer = 0
	# Setup scene manager
	SceneManager.set_canvas_layer(canvas_layer)
	SceneManager.initialize_scene_dictionary()

func setup_connections():
	# Connect game controller signals
	game_controller.scene_change_requested.connect(_on_scene_change_requested)
	game_controller.game_state_changed.connect(_on_game_state_changed)
	
	# Connect scene manager signals
	SceneManager.scene_changed.connect(_on_scene_changed)

func start_game():
	print("Starting game from main.gd")
	# Set up input devices
	InputManager.initialize_player_devices()
	InputManager.set_white_player_device("keyboard", 0, "White") #Params are device type, deivce id, color for printing
	InputManager.set_black_player_device("keyboard", 1, "Black")  # If using keyboard and controller both devices ids are 0. Seccond contrller is 1
	
	# Start at title screen
	request_scene_change("chess")

# Public API for scene changes
func request_scene_change(scene_name: String):
	game_controller.request_scene_change(scene_name)

func request_duel_transition():
	game_controller.request_duel_transition()

func request_duel_exit():
	game_controller.request_duel_exit()

func get_game_controller() -> MainGameController:
	return game_controller

# Signal handlers
func _on_scene_change_requested(scene_name: String):
	print("Scene change requested: ", scene_name)
	
	# Handle special duel transitions
	match scene_name:
		"duel_transition":
			SceneManager.transition_to_duel()
		_:
			SceneManager.change_scene(scene_name)

func _on_game_state_changed(new_state: MainConstants.GameState):
	print("Game state changed to: ", MainConstants.GameState.keys()[new_state])

func _on_scene_changed(scene_name: String):
	print("Scene changed to: ", scene_name)
	connect_scene_signals()

func connect_scene_signals():
	var current_scene = SceneManager.get_current_scene()
	if not current_scene:
		return
	
	# Connect scene signals to main
	if current_scene.has_signal("request_scene_change"):
		if not current_scene.request_scene_change.is_connected(_on_scene_change_requested):
			current_scene.request_scene_change.connect(_on_scene_change_requested)
