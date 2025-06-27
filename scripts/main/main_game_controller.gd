class_name MainGameController
extends RefCounted

# Signals for game state changes
signal game_state_changed(new_state: MainConstants.GameState)
signal game_type_changed(new_type: MainConstants.GameType)
signal scene_change_requested(scene_name: String)

# Core game state
var current_game_state: MainConstants.GameState = MainConstants.GameState.MENU
var current_game_type: MainConstants.GameType = MainConstants.GameType.CHESS
var saved_game_states: Dictionary = {}
var session_data: Dictionary = {}
var board_state: Array[Array] = []
var current_turn: int = 1

func generate_session_id() -> String:
	return "session_" + str(Time.get_unix_time_from_system())

# Game state management
func change_game_state(new_state: MainConstants.GameState):
	if current_game_state != new_state:
		current_game_state = new_state
		game_state_changed.emit(new_state)

func change_game_type(new_type: MainConstants.GameType):
	if current_game_type != new_type:
		current_game_type = new_type
		game_type_changed.emit(new_type)

func get_current_game_state() -> MainConstants.GameState:
	return current_game_state

func get_current_game_type() -> MainConstants.GameType:
	return current_game_type

# Scene management
func request_scene_change(scene_name: String):
	# Determine game type from scene
	var new_game_type = MainConstants.get_game_type_from_scene(scene_name)
	change_game_type(new_game_type)
	
	# Set appropriate game state
	match scene_name:
		MainConstants.SCENE_NAMES.title_screen:
			change_game_state(MainConstants.GameState.MENU)
		MainConstants.SCENE_NAMES.main_menu:
			change_game_state(MainConstants.GameState.MENU)
		MainConstants.SCENE_NAMES.chess, MainConstants.SCENE_NAMES.chess:
			change_game_state(MainConstants.GameState.IN_GAME)
	
	# Emit signal to main for actual scene change
	scene_change_requested.emit(scene_name)

# Save/Load game states
func save_game_state(game_type: MainConstants.GameType, state_data: Dictionary):
	var key = MainConstants.GameType.keys()[game_type].to_lower()
	saved_game_states[key] = {
		"data": state_data,
		"timestamp": Time.get_unix_time_from_system(),
		"game_type": game_type,
		"version": "1.0"
	}

# Utility methods
func is_in_game() -> bool:
	return current_game_state == MainConstants.GameState.IN_GAME

func is_in_menu() -> bool:
	return current_game_state == MainConstants.GameState.MENU
