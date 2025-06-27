extends RefCounted
class_name MainConstants

# Game Types - only chess for now
enum GameType {
	CHESS = 0
}

# Game States
enum GameState {
	TITLE,
	MENU,
	IN_GAME,
}

# Scene Names - centralized scene references
const SCENE_NAMES := {
	"title_screen": "title_screen",
	"chess": "chess",
	"main_menu": "main_menu"
}

# Helper Functions
static func get_scene_name(game_type: GameType) -> String:
	match game_type:
		GameType.CHESS:
			return SCENE_NAMES.chess
		_:
			return SCENE_NAMES.title_screen

static func get_game_type_from_scene(scene_name: String) -> GameType:
	match scene_name:
		"chess":
			return GameType.CHESS
		_:
			return GameType.CHESS  # Only chess for now 
