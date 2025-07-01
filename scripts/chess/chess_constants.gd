extends RefCounted
class_name ChessConstants

# Board constants
const BOARD_SIZE := 8
const TILE_SIZE := 24

# Team colors
enum TeamColor {
	WHITE = 0,
	BLACK = 1
}

# Game states
enum GameState {
	WHITE_TURN,
	BLACK_TURN,
	GAME_OVER,
	PAUSED
}

# Player IDs
enum PlayerId {
	WHITE_PLAYER = 1,
	BLACK_PLAYER = 2
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
	TeamColor.WHITE: Color(1.0, 1.0, 0.0),
	TeamColor.BLACK: Color(1.0, 1.0, 0.0)
}

const SELECTION_COLOR := Color.GREEN
const VALID_MOVE_COLOR := Color.BLUE
const LIGHT_TILE_COLOR := Color(0.85, 0.75, 0.6)
const DARK_TILE_COLOR := Color(0.4, 0.25, 0.1)

# Helper functions
static func get_team_from_player_id(player_id: PlayerId) -> TeamColor:
	return TeamColor.WHITE if player_id == PlayerId.WHITE_PLAYER else TeamColor.BLACK

static func get_player_id_from_team(team: TeamColor) -> PlayerId:
	return PlayerId.WHITE_PLAYER if team == TeamColor.WHITE else PlayerId.BLACK_PLAYER

static func get_game_state_from_team(team: TeamColor) -> GameState:
	return GameState.WHITE_TURN if team == TeamColor.WHITE else GameState.BLACK_TURN

static func get_team_from_game_state(state: GameState) -> TeamColor:
	return TeamColor.WHITE if state == GameState.WHITE_TURN else TeamColor.BLACK 
