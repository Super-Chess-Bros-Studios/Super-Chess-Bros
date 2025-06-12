extends Node2D

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

#So TilesContainer just contains a bunch of scenes of tile which we import as a packed scene
@onready var tiles_container := $TilesContainer
@export var tile_scene: PackedScene

#So each chess piece is going to be a piece scene and we populate it with respective sprite
@export var piece_scene: PackedScene
@export var piece_sprite_sheet: Texture

# The camera controls the view port of chess portion
@onready var camera_2d: Camera2D = $Camera2D

# We get board center so we can position camera correctly
var board_center = Vector2(BOARD_SIZE * TILE_SIZE, BOARD_SIZE * TILE_SIZE) / 2

func _ready():
	spawn_board()
	spawn_pieces()
	$Camera2D.position = board_center

# Populates our board with respective tiles
func spawn_board():
	for row in BOARD_SIZE:
		for col in BOARD_SIZE:
			var tile = tile_scene.instantiate()
			tile.position = Vector2(col, row) * TILE_SIZE
			tile.name = "Tile_%d_%d" % [row, col]
			tile.board_position = Vector2i(col, row)
			tiles_container.add_child(tile)
			tile.set_tile_color((col + row) % 2 == 0)

# Our function that spawns the respective piece
func spawn_piece(piece_type: String, is_white: bool, position: Vector2i, point_value: int):
	var scene = PIECE_SCENES[piece_type]
	var piece = scene.instantiate()
	add_child(piece)
	piece.setup(is_white, position, piece_sprite_sheet, point_value, TILE_SIZE)

func spawn_pieces():
	# Pawns
	for col in range(8):
		spawn_piece("pawn", true, Vector2i(col, 6), 1)   # white pawns
		spawn_piece("pawn", false, Vector2i(col, 1), 1)  # black pawns

	# Rooks
	spawn_piece("rook", true, Vector2i(0, 7), 5)
	spawn_piece("rook", true, Vector2i(7, 7), 5)
	spawn_piece("rook", false, Vector2i(0, 0), 5)
	spawn_piece("rook", false, Vector2i(7, 0), 5)

	# Knights
	spawn_piece("knight", true, Vector2i(1, 7), 3)
	spawn_piece("knight", true, Vector2i(6, 7), 3)
	spawn_piece("knight", false, Vector2i(1, 0), 3)
	spawn_piece("knight", false, Vector2i(6, 0), 3)

	# Bishops
	spawn_piece("bishop", true, Vector2i(2, 7), 3)
	spawn_piece("bishop", true, Vector2i(5, 7), 3)
	spawn_piece("bishop", false, Vector2i(2, 0), 3)
	spawn_piece("bishop", false, Vector2i(5, 0), 3)

	# Queens
	spawn_piece("queen", true, Vector2i(3, 7), 9)
	spawn_piece("queen", false, Vector2i(3, 0), 9)

	# Kings
	spawn_piece("king", true, Vector2i(4, 7), 0)
	spawn_piece("king", false, Vector2i(4, 0), 0)
