extends Node2D


func _ready():
	initialize_systems()
	setup_connections()
	start_game()

func initialize_systems():
	# Setup scene manager
	SceneManager.initialize_scene_dictionary()
	SceneManager.set_main(self)

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
