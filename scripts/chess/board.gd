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

# Cursor scenes - now we have two cursors
@onready var white_cursor: Node2D = preload("res://scenes/chess/cursor.tscn").instantiate()
@onready var black_cursor: Node2D = preload("res://scenes/chess/cursor.tscn").instantiate()

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

# Cursor tracking - now we track both cursors
var white_cursor_tile_pos: Vector2i = Vector2i(-1, -1)
var black_cursor_tile_pos: Vector2i = Vector2i(-1, -1)

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

func _ready():
	spawn_board()
	initialize_board_state()
	spawn_pieces()
	$Camera2D.position = board_center
	
	# Setup cursors
	add_child(white_cursor)
	add_child(black_cursor)
	
	# Set player IDs for cursors
	white_cursor.player_id = 1
	black_cursor.player_id = 2
	
	# Set initial positions
	white_cursor.cursor_pos = board_center
	black_cursor.cursor_pos = board_center
	
	# Pass tile_size to cursors
	white_cursor.tile_size = TILE_SIZE
	black_cursor.tile_size = TILE_SIZE

func _process(delta):
	# Handle accept/cancel inputs for both players
	if Input.is_action_just_pressed("accept_1"):
		handle_tile_click(1)
	if Input.is_action_just_pressed("cancel_1") and selected_piece != null:
		deselect_piece()
		
	if Input.is_action_just_pressed("accept_2"):
		handle_tile_click(2)
	if Input.is_action_just_pressed("cancel_2") and selected_piece != null:
		deselect_piece()

# This function is called by the cursor scripts when they hover over tiles
func cursor_hovered(tile_pos: Vector2i, player_id: int):
	var old_tile_pos: Vector2i
	
	# Determine which cursor moved and get the old position
	if player_id == 1:  # White cursor
		old_tile_pos = white_cursor_tile_pos
		white_cursor_tile_pos = tile_pos
	else:  # Black cursor
		old_tile_pos = black_cursor_tile_pos
		black_cursor_tile_pos = tile_pos
	
	# Clear previous highlight if it exists
	if old_tile_pos != Vector2i(-1, -1):
		var prev_tile = get_tile_at_position(old_tile_pos)
		if prev_tile:
			# Only remove if not selected tile
			if selected_piece == null or old_tile_pos != selected_piece.board_position:
				prev_tile.reset_color()
	
	# Set new highlight
	var tile = get_tile_at_position(tile_pos)
	if tile:
		var piece_at_tile = board_state[tile_pos.y][tile_pos.x]
		if selected_piece == null or (piece_at_tile != selected_piece):
			# Use appropriate color based on current turn
			tile.highlight(turn_colors[current_turn])
		else:
			# Selected piece tile stays green
			tile.highlight(Color.GREEN)

# Handle tile clicks from either cursor
func handle_tile_click(player_id: int):
	var tile_pos: Vector2i
	
	# Get the tile position based on which cursor clicked
	if player_id == 1:
		tile_pos = white_cursor_tile_pos
	else:
		tile_pos = black_cursor_tile_pos
	
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

# Our function that spawns the respective piece
func spawn_piece(piece_type: String, _team, position: Vector2i, point_value: int):
	var scene = PIECE_SCENES[piece_type]
	var piece = scene.instantiate()
	add_child(piece)
	piece.setup(_team, position, piece_sprite_sheet, point_value, TILE_SIZE)
	board_state[position.y][position.x] = piece
	# can remove position inside of name eventually, but using it for debug currently 
	piece.name = "%s_%s_%d_%d" % [piece_type, "white" if _team == TEAM_COLOR.WHITE else "black", position.x, position.y]

func spawn_pieces():
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
	
	# Update highlights for both cursors after turn switch
	if white_cursor_tile_pos != Vector2i(-1, -1):
		var tile = get_tile_at_position(white_cursor_tile_pos)
		if tile:
			tile.highlight(turn_colors[current_turn])
	
	if black_cursor_tile_pos != Vector2i(-1, -1):
		var tile = get_tile_at_position(black_cursor_tile_pos)
		if tile:
			tile.highlight(turn_colors[current_turn])
