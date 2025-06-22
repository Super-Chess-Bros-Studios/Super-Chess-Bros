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

var board_state: Array
var piece_parent: Node
var piece_sprite_sheet: Texture

enum TEAM_COLOR {WHITE, BLACK}

func setup(_board_state: Array, _piece_parent: Node, _piece_sprite_sheet: Texture):
	board_state = _board_state
	piece_parent = _piece_parent
	piece_sprite_sheet = _piece_sprite_sheet

# Our function that spawns the respective piece
func spawn_piece(piece_type: String, _team, position: Vector2i, point_value: int):
	var scene = PIECE_SCENES[piece_type]
	var piece = scene.instantiate()
	piece_parent.add_child(piece)
	piece.setup(_team, position, piece_sprite_sheet, point_value, TILE_SIZE)
	board_state[position.y][position.x] = piece
	# can remove position inside of name eventually, but using it for debug currently 
	piece.name = "%s_%s_%d_%d" % [piece_type, "white" if _team == TEAM_COLOR.WHITE else "black", position.x, position.y]

func spawn_all_pieces():
	# Pawns
	for col in range(8):
		spawn_piece("pawn", TEAM_COLOR.WHITE, Vector2i(col, 6), 1)   # white pawns
		spawn_piece("pawn", TEAM_COLOR.BLACK, Vector2i(col, 1), 1)  # black pawns

	# Rooks
	spawn_piece("rook", TEAM_COLOR.WHITE, Vector2i(0, 7), 5)
	spawn_piece("rook", TEAM_COLOR.WHITE, Vector2i(7, 7), 5)
	spawn_piece("rook", TEAM_COLOR.BLACK, Vector2i(0, 0), 5)
	spawn_piece("rook", TEAM_COLOR.BLACK, Vector2i(7, 0), 5)

	# Knights
	spawn_piece("knight", TEAM_COLOR.WHITE, Vector2i(1, 7), 3)
	spawn_piece("knight", TEAM_COLOR.WHITE, Vector2i(6, 7), 3)
	spawn_piece("knight", TEAM_COLOR.BLACK, Vector2i(1, 0), 3)
	spawn_piece("knight", TEAM_COLOR.BLACK, Vector2i(6, 0), 3)

	# Bishops
	spawn_piece("bishop", TEAM_COLOR.WHITE, Vector2i(2, 7), 3)
	spawn_piece("bishop", TEAM_COLOR.WHITE, Vector2i(5, 7), 3)
	spawn_piece("bishop", TEAM_COLOR.BLACK, Vector2i(2, 0), 3)
	spawn_piece("bishop", TEAM_COLOR.BLACK, Vector2i(5, 0), 3)

	# Queens
	spawn_piece("queen", TEAM_COLOR.WHITE, Vector2i(3, 7), 9)
	spawn_piece("queen", TEAM_COLOR.BLACK, Vector2i(3, 0), 9)

	# Kings
	spawn_piece("king", TEAM_COLOR.WHITE, Vector2i(4, 7), 0)
	spawn_piece("king", TEAM_COLOR.BLACK, Vector2i(4, 0), 0) 
