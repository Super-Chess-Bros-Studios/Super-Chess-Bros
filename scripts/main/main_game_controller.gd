class_name MainGameController
extends RefCounted

# Simple state management
signal game_state_changed(new_state: MainConstants.GameState)
signal scene_change_requested(scene_name: String)

# Core game state
var current_game_state: MainConstants.GameState = MainConstants.GameState.MENU
var session_data: Dictionary = {}

func change_game_state(new_state: MainConstants.GameState):
	if current_game_state != new_state:
		current_game_state = new_state
		game_state_changed.emit(new_state)

func get_current_game_state() -> MainConstants.GameState:
	return current_game_state

# Scene management requests
func request_scene_change(scene_name: String):
	# Update game state based on scene
	match scene_name:
		"title", "main_menu":
			change_game_state(MainConstants.GameState.MENU)
		"chess", "dual_arena":
			change_game_state(MainConstants.GameState.IN_GAME)
	
	scene_change_requested.emit(scene_name)

# Special duel transitions
func request_duel_transition():
	change_game_state(MainConstants.GameState.IN_GAME)
	scene_change_requested.emit("duel_transition")

func request_duel_exit():
	change_game_state(MainConstants.GameState.IN_GAME)
	scene_change_requested.emit("duel_exit")
