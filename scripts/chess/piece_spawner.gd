extends Node

class_name PieceSpawner

const BOARD_SIZE := 8
const TILE_SIZE := 24

const PIECE_SCENES := {
	"pawn": preload("res://scenes/chess/pieces/pawn.tscn"),
	"rook": preload("res://scenes/chess/pieces/rook.tscn"),
	"knight": preload("res://scenes/chess/pieces/knight.tscn"),
	"bishop": preload("res://scenes/chess/pieces/bishop.tscn"),
	"queen": preload("res://scenes/chess/pieces/queen.tscn"),
	"king": preload("res://scenes/chess/pieces/king.tscn")
}

var game_manager: GameManager
var piece_parent: Node
var piece_sprite_sheet: Texture

func setup(_game_manager: GameManager, _piece_parent: Node, _piece_sprite_sheet: Texture):
	game_manager = _game_manager
	piece_parent = _piece_parent
	piece_sprite_sheet = _piece_sprite_sheet

func spawn_piece(piece_type: String, team: InputManager.TeamColor, position: Vector2i) -> Piece:
	var scene = PIECE_SCENES[piece_type]
	var piece = scene.instantiate()
	piece_parent.add_child(piece)
	
	var point_value = ChessConstants.PIECE_VALUES[piece_type]
	piece.setup(team, position, piece_sprite_sheet, point_value, ChessConstants.TILE_SIZE)
	game_manager.set_piece_at_position(position, piece)
	
	# Set piece name for debugging
	var team_name = "white" if team == InputManager.TeamColor.WHITE else "black"
	piece.name = "%s_%s_%d_%d" % [piece_type, team_name, position.x, position.y]
	
	return piece

func spawn_all_pieces():
	# Pawns
	for col in range(8):
		spawn_piece("pawn", InputManager.TeamColor.WHITE, Vector2i(col, 6))
		spawn_piece("pawn", InputManager.TeamColor.BLACK, Vector2i(col, 1))

	# Rooks
	spawn_piece("rook", InputManager.TeamColor.WHITE, Vector2i(0, 7))
	spawn_piece("rook", InputManager.TeamColor.WHITE, Vector2i(7, 7))
	spawn_piece("rook", InputManager.TeamColor.BLACK, Vector2i(0, 0))
	spawn_piece("rook", InputManager.TeamColor.BLACK, Vector2i(7, 0))

	# Knights
	spawn_piece("knight", InputManager.TeamColor.WHITE, Vector2i(1, 7))
	spawn_piece("knight", InputManager.TeamColor.WHITE, Vector2i(6, 7))
	spawn_piece("knight", InputManager.TeamColor.BLACK, Vector2i(1, 0))
	spawn_piece("knight", InputManager.TeamColor.BLACK, Vector2i(6, 0))

	# Bishops
	spawn_piece("bishop", InputManager.TeamColor.WHITE, Vector2i(2, 7))
	spawn_piece("bishop", InputManager.TeamColor.WHITE, Vector2i(5, 7))
	spawn_piece("bishop", InputManager.TeamColor.BLACK, Vector2i(2, 0))
	spawn_piece("bishop", InputManager.TeamColor.BLACK, Vector2i(5, 0))

	# Queens
	spawn_piece("queen", InputManager.TeamColor.WHITE, Vector2i(3, 7))
	spawn_piece("queen", InputManager.TeamColor.BLACK, Vector2i(3, 0))

	# Kings
	spawn_piece("king", InputManager.TeamColor.WHITE, Vector2i(4, 7))
	spawn_piece("king", InputManager.TeamColor.BLACK, Vector2i(4, 0)) 
