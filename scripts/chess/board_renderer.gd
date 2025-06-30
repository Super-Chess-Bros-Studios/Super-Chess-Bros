class_name BoardRenderer
extends Node2D

signal tile_hovered(tile_pos: Vector2i, player_id: ChessConstants.PlayerId)

@onready var tiles_container := $TilesContainer
@export var tile_scene: PackedScene

var tile_references: Array[Array] = []

func _ready():
	create_board()

func create_board():
	# Initialize tile references array
	tile_references.clear()
	for y in range(ChessConstants.BOARD_SIZE):
		var row: Array[Node2D] = []
		row.resize(ChessConstants.BOARD_SIZE)
		tile_references.append(row)
	
	# Create tiles
	for row in ChessConstants.BOARD_SIZE:
		for col in ChessConstants.BOARD_SIZE:
			var tile = tile_scene.instantiate()
			tile.position = Vector2(col, row) * ChessConstants.TILE_SIZE
			tile.name = "Tile_%d_%d" % [row, col]
			tile.board_position = Vector2i(col, row)
			tiles_container.add_child(tile)
			tile.set_tile_color((col + row) % 2 == 0)
			tile_references[row][col] = tile

func get_tile_at_position(pos: Vector2i) -> Node2D:
	if is_valid_position(pos):
		return tile_references[pos.y][pos.x]
	return null

func is_valid_position(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < ChessConstants.BOARD_SIZE and pos.y >= 0 and pos.y < ChessConstants.BOARD_SIZE

func highlight_tile(pos: Vector2i, color: Color):
	var tile = get_tile_at_position(pos)
	if tile:
		tile.highlight(color)

func reset_tile_color(pos: Vector2i):
	var tile = get_tile_at_position(pos)
	if tile:
		tile.reset_color()

func reset_all_tiles():
	for row in ChessConstants.BOARD_SIZE:
		for col in ChessConstants.BOARD_SIZE:
			reset_tile_color(Vector2i(col, row))
			
func get_board_center() -> Vector2:
	return Vector2(ChessConstants.BOARD_SIZE * ChessConstants.TILE_SIZE, ChessConstants.BOARD_SIZE * ChessConstants.TILE_SIZE) / 2 
