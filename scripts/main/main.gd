extends Node

@onready var canvas_layer: CanvasLayer = $CanvasLayer

func _ready():
	initialize_systems()
	setup_connections()
	start_game()

func initialize_systems():
	canvas_layer.follow_viewport_enabled = true
	canvas_layer.layer = 0
	# Setup scene manager
	SceneManager.set_canvas_layer(canvas_layer)
	SceneManager.initialize_scene_dictionary()

func setup_connections():
	# Connect scene manager signals
	SceneManager.scene_changed.connect(_on_scene_changed)

func start_game():
	print("Starting game from main.gd")
	
	# Start at title screen
	request_scene_change("chess")

# Public API for scene changes
func request_scene_change(scene_name: String):
	SceneManager.change_scene(scene_name)

func _on_scene_changed(scene_name: String):
	print("Scene changed to: ", scene_name)
	connect_scene_signals()

func connect_scene_signals():
	var current_scene = SceneManager.get_current_scene()
	if not current_scene:
		return
