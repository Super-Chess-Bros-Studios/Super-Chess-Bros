extends RefCounted
class_name MainConstants

# Game States
enum GameState {
	TITLE,
	MENU,
	IN_GAME,
}

# Scene Names - centralized scene references
const SCENE_NAMES := {
	"title": "title",
	"chess": "chess",
	"main_menu": "main_menu",
	"dual_arena": "dual_arena"
}
