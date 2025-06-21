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

# Cursor scene
@onready var cursor: Node2D = preload("res://scenes/chess/cursor.tscn").instantiate()

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

# cursor settings 
var cursor_pos := Vector2i(4, 4)
var cursor_speed := 300.0
var tile_pos: Vector2i = Vector2i(-1, -1)

#chess logic
var board_state := [] # Game state of the board
var selected_piece: Piece = null
enum team {white, black}
var current_turn : team = team.white # Logic for chess turns

# Hovering colors for both sides
var turn_colors := {
	team.white : Color(0.9, 0.9, 1.0),
	team.black : Color(0.2, 0.2, 0.4)
}

func _ready():
	spawn_board()
	initialize_board_state()
	spawn_pieces()
	$Camera2D.position = board_center
	add_child(cursor)
	cursor.position = board_center

func _process(delta):
	handle_controller_input(delta)

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
	piece.name = "%s_%s_%d_%d" % [piece_type, "white" if _team == team.white else "black", position.x, position.y]

func spawn_pieces():
	# Pawns
	for col in range(8):
		spawn_piece("pawn", team.white, Vector2i(col, 6), 1)   # white pawns
		spawn_piece("pawn", team.black, Vector2i(col, 1), 1)  # black pawns

	# Rooks
	spawn_piece("rook", team.white, Vector2i(0, 7), 5)
	spawn_piece("rook", team.white, Vector2i(7, 7), 5)
	spawn_piece("rook", team.black, Vector2i(0, 0), 5)
	spawn_piece("rook", team.black, Vector2i(7, 0), 5)

	# Knights
	spawn_piece("knight", team.white, Vector2i(1, 7), 3)
	spawn_piece("knight", team.white, Vector2i(6, 7), 3)
	spawn_piece("knight", team.black, Vector2i(1, 0), 3)
	spawn_piece("knight", team.black, Vector2i(6, 0), 3)

	# Bishops
	spawn_piece("bishop", team.white, Vector2i(2, 7), 3)
	spawn_piece("bishop", team.white, Vector2i(5, 7), 3)
	spawn_piece("bishop", team.black, Vector2i(2, 0), 3)
	spawn_piece("bishop", team.black, Vector2i(5, 0), 3)

	# Queens
	spawn_piece("queen", team.white, Vector2i(3, 7), 9)
	spawn_piece("queen", team.black, Vector2i(3, 0), 9)

	# Kings
	spawn_piece("king", team.white, Vector2i(4, 7), 0)
	spawn_piece("king", team.black, Vector2i(4, 0), 0)

func handle_controller_input(delta):
	# controller input vectors
	var input_vector := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	
	# hide highlight until cursor is moved
	if input_vector.length() > 0.1:
		update_hovered_tile()
	
	# diagonal movement
	if input_vector.length() > 1.0:
		input_vector = input_vector.normalized()
	
	# Move cursor
	cursor.position += input_vector * cursor_speed * delta
	
	# Keep cursor on the board
	cursor.position.x = clamp(cursor.position.x, 0, BOARD_SIZE * TILE_SIZE)
	cursor.position.y = clamp(cursor.position.y, 0, BOARD_SIZE * TILE_SIZE)
	
	# buttons
	if Input.is_action_just_pressed("ui_accept"):
		tile_clicked()
	if Input.is_action_just_pressed("ui_cancel") and selected_piece != null:
		deselect_piece()

func update_hovered_tile():
	# Convert cursor position to tile coordinates
	var new_hover := Vector2i(
		floor(cursor.position.x / TILE_SIZE),
		floor(cursor.position.y / TILE_SIZE)
	)
	
	# Clamp to board size
	new_hover.x = clamp(new_hover.x, 0, BOARD_SIZE - 1)
	new_hover.y = clamp(new_hover.y, 0, BOARD_SIZE - 1)
	
	# update highlight if when we change tiles
	if new_hover != tile_pos:
		# Clear previous highlight
		if tile_pos != Vector2i(-1, -1):
			var prev_tile = get_tile_at_position(tile_pos)
			if prev_tile:
				# only remove if not selected tile
				if selected_piece == null or tile_pos != selected_piece.board_position:
					prev_tile.reset_color()
			
		# Set next highlight
		tile_pos = new_hover
		var tile = get_tile_at_position(tile_pos)
		if tile:
			var piece_at_tile = board_state[tile_pos.y][tile_pos.x]
			if selected_piece == null or (piece_at_tile != selected_piece):
				tile.highlight(turn_colors[current_turn])
			else:
				# selected piece tile stays green
				tile.highlight(Color.GREEN)

# Get tile using its name format "Tile_{row}_{col}"
func get_tile_at_position(pos: Vector2i) :
	var tile_name = "Tile_%d_%d" % [pos.y, pos.x] 
	return tiles_container.get_node_or_null(tile_name)

func tile_clicked():
	var tile_pos := Vector2i(
		floor(cursor.position.x / TILE_SIZE),
		floor(cursor.position.y / TILE_SIZE)
	)
	tile_pos.x = clamp(tile_pos.x, 0, BOARD_SIZE - 1)
	tile_pos.y = clamp(tile_pos.y, 0, BOARD_SIZE - 1)
	
	print("Clicked Tile: [",tile_pos.x,",",tile_pos.y,"]") #debug
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

func deselect_piece():
	if selected_piece != null:
		get_tile_at_position(selected_piece.board_position).reset_color()
		selected_piece = null

func switch_turn():
	# switch team
	current_turn = team.black if current_turn == team.white else team.white
	
	# clear tile highlight on turn switch
	if tile_pos != Vector2i(-1, -1):
		get_tile_at_position(tile_pos).highlight(
			turn_colors[team.white] if current_turn == team.white else turn_colors[team.black])
