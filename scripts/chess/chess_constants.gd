extends RefCounted
class_name ChessConstants

# Board constants
const BOARD_SIZE := 8
const TILE_SIZE := 24

# Game states
enum GameState {
	WHITE_TURN,
	BLACK_TURN,
	GAME_OVER,
	PAUSED
}

# Piece values
const PIECE_VALUES := {
	"pawn": 1,
	"knight": 3,
	"bishop": 3,
	"rook": 5,
	"queen": 9,
	"king": 0
}

# UI Colors
const HOVER_COLORS := {
	InputManager.TeamColor.WHITE: Color(1.0, 1.0, 0.0),
	InputManager.TeamColor.BLACK: Color(1.0, 1.0, 0.0)
}

const SELECTION_COLOR := Color.GREEN
const VALID_MOVE_COLOR := Color.BLUE
const LIGHT_TILE_COLOR := Color(0.85, 0.75, 0.6)
const DARK_TILE_COLOR := Color(0.4, 0.25, 0.1)

# Helper functions
static func get_game_state_from_team(team: InputManager.TeamColor) -> GameState:
	return GameState.WHITE_TURN if team == InputManager.TeamColor.WHITE else GameState.BLACK_TURN

static func get_team_from_game_state(state: GameState) -> InputManager.TeamColor:
	return InputManager.TeamColor.WHITE if state == GameState.WHITE_TURN else InputManager.TeamColor.BLACK 
