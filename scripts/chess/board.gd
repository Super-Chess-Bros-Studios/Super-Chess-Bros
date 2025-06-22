extends Node2D

const BOARD_SIZE := 8
const TILE_SIZE := 24

# Get cursor references from scene children
@onready var white_cursor: Node2D = $WhiteCursor
@onready var black_cursor: Node2D = $BlackCursor

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

#chess logic
var board_state := [] # Game state of the board
var selected_piece: Piece = null
enum TEAM_COLOR {WHITE, BLACK}
var current_turn : TEAM_COLOR = TEAM_COLOR.WHITE # Logic for chess turns

# Hovering colors for both sides
var turn_colors := {
	TEAM_COLOR.WHITE : Color(0.9, 0.9, 1.0),
	TEAM_COLOR.BLACK : Color(0.2, 0.2, 0.4)
}

# Piece spawner instance
var piece_spawner: PieceSpawner

func _ready():
	spawn_board()
	initialize_board_state()
	
	# Initialize piece spawner
	piece_spawner = PieceSpawner.new()
	piece_spawner.setup(board_state, self, piece_sprite_sheet)
	piece_spawner.spawn_all_pieces()
	
	$Camera2D.position = board_center
	
	# Set initial positions
	white_cursor.cursor_pos = board_center
	black_cursor.cursor_pos = board_center

func _process(delta):
	pass  # Removed cursor_select as it's now handled in cursor.gd

# Handle tile clicks from either cursor
func handle_tile_click(player_id: int):
	var tile_pos: Vector2i
	
	# Get the tile position from the appropriate cursor
	if player_id == 1:
		tile_pos = white_cursor.get_current_tile_pos()
	else:
		tile_pos = black_cursor.get_current_tile_pos()
	
	# Only allow moves during the appropriate turn
	if (current_turn == TEAM_COLOR.WHITE and player_id != 1) or (current_turn == TEAM_COLOR.BLACK and player_id != 2):
		return  # Not this player's turn
	
	print("Player ", player_id, " clicked Tile: [", tile_pos.x, ",", tile_pos.y, "]") #debug
	var piece = board_state[tile_pos.y][tile_pos.x]
	
	# If no piece is selected and we're on a piece of our color
	if selected_piece == null and piece != null and piece.team == current_turn:
		selected_piece = piece
		print("Selected Piece: ", selected_piece.name) # debug
		get_tile_at_position(tile_pos).highlight(Color.GREEN)
		return
	
	if selected_piece != null:
		# Movement logic will go here
		switch_turn()
		deselect_piece()

# Handle cancel selection from cursor
func handle_cancel_selection(player_id: int):
	# Only allow cancel during the appropriate turn
	if (current_turn == TEAM_COLOR.WHITE and player_id != 1) or (current_turn == TEAM_COLOR.BLACK and player_id != 2):
		return  # Not this player's turn
	
	if selected_piece != null:
		deselect_piece()

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

# Create a game state with null values
func initialize_board_state():
	board_state = []
	for y in range(BOARD_SIZE):
		var row := []
		for x in range(BOARD_SIZE):
			row.append(null)
		board_state.append(row)

# Get tile using its name format "Tile_{row}_{col}"
func get_tile_at_position(pos: Vector2i) :
	var tile_name = "Tile_%d_%d" % [pos.y, pos.x] 
	return tiles_container.get_node_or_null(tile_name)

func deselect_piece():
	if selected_piece != null:
		get_tile_at_position(selected_piece.board_position).reset_color()
		selected_piece = null

func switch_turn():
	# switch team
	current_turn = TEAM_COLOR.BLACK if current_turn == TEAM_COLOR.WHITE else TEAM_COLOR.WHITE
	
	# Update highlights for the cursors after turn switch
	white_cursor.update_hover()
	black_cursor.update_hover()
