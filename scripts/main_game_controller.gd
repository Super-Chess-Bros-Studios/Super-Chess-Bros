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

func get_saved_game_state(game_type: MainConstants.GameType) -> Dictionary:
	var key = MainConstants.GameType.keys()[game_type].to_lower()
	var saved_state = saved_game_states.get(key, {})
	return saved_state.get("data", {})

func has_saved_game_state(game_type: MainConstants.GameType) -> bool:
	var key = MainConstants.GameType.keys()[game_type].to_lower()
	return key in saved_game_states and not saved_game_states[key].get("data", {}).is_empty()

func clear_saved_game_state(game_type: MainConstants.GameType):
	var key = MainConstants.GameType.keys()[game_type].to_lower()
	if key in saved_game_states:
		saved_game_states.erase(key)

# Session management
func update_session_stats(games_completed: int = 0, play_time_delta: float = 0.0):
	session_data.games_completed += games_completed
	session_data.total_play_time += play_time_delta

func get_session_data() -> Dictionary:
	return session_data.duplicate()

# Save/Load to disk
func prepare_save_data() -> Dictionary:
	return {
		"saved_game_states": saved_game_states,
		"session_data": session_data,
		"timestamp": Time.get_unix_time_from_system(),
		"version": "1.0"
	}

func load_from_save_data(save_data: Dictionary):
	if save_data.has("saved_game_states"):
		saved_game_states = save_data.saved_game_states
	if save_data.has("session_data"):
		session_data = save_data.session_data

# Utility methods
func is_in_game() -> bool:
	return current_game_state == MainConstants.GameState.IN_GAME

func is_in_menu() -> bool:
	return current_game_state == MainConstants.GameState.MENU

func can_save_game() -> bool:
	return is_in_game()

func can_load_game() -> bool:
	return has_saved_game_state(current_game_type) 
