extends Node2D

# Scene references
@onready var white_cursor: Node2D = $WhiteCursor
@onready var black_cursor: Node2D = $BlackCursor
@onready var board_renderer: BoardRenderer = $BoardRenderer
@onready var camera_2d: Camera2D = $Camera2D

# Export properties
@export var piece_sprite_sheet: Texture

# Core systems
var game_manager: GameManager
var piece_spawner: PieceSpawner

func _ready():
	initialize_systems()
	setup_camera()
	setup_cursors()
	spawn_initial_pieces()
	connect_signals()

func initialize_systems():
	# Initialize game manager
	game_manager = GameManager.new()
	
	# Initialize piece spawner
	piece_spawner = PieceSpawner.new()
	add_child(piece_spawner)
	piece_spawner.setup(game_manager, self, piece_sprite_sheet)

func setup_camera():
	print(board_renderer)
	var board_center = board_renderer.get_board_center()
	camera_2d.position = board_center

func setup_cursors():
	var board_center = board_renderer.get_board_center()
	
	# Setup white cursor
	white_cursor.cursor_pos = board_center
	white_cursor.setup(game_manager, board_renderer)
	
	# Setup black cursor  
	black_cursor.cursor_pos = board_center
	black_cursor.setup(game_manager, board_renderer)

func spawn_initial_pieces():
	piece_spawner.spawn_all_pieces()

func connect_signals():
	# Connect game manager signals
	game_manager.game_state_changed.connect(_on_game_state_changed)
	game_manager.piece_selected.connect(_on_piece_selected)
	game_manager.piece_deselected.connect(_on_piece_deselected)
	game_manager.turn_switched.connect(_on_turn_switched)

# Signal handlers
func _on_game_state_changed(new_state: ChessConstants.GameState):
	print("Game state changed to: ", new_state)

func _on_piece_selected(piece: Piece):
	print("Piece selected: ", piece.name)

func _on_piece_deselected():
	print("Piece deselected")

func _on_turn_switched(new_team: ChessConstants.TeamColor):
	print("Turn switched to: ", "White" if new_team == ChessConstants.TeamColor.WHITE else "Black")
	
	# Update cursor highlights after turn switch
	white_cursor.update_hover_after_turn_switch()
	black_cursor.update_hover_after_turn_switch()

# Public API for accessing systems
func get_game_manager() -> GameManager:
	return game_manager

func get_board_renderer() -> BoardRenderer:
	return board_renderer

func get_piece_spawner() -> PieceSpawner:
	return piece_spawner
