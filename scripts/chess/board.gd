extends Node2D

# =============================================================================
# CHESS GAME SYSTEM - MAIN COORDINATOR
# =============================================================================
#
# This is the main coordinator for the chess game system. It initializes and
# manages all subsystems, coordinates communication between components, and
# provides a clean public API for accessing game systems.
#
# =============================================================================
# SYSTEM ARCHITECTURE
# =============================================================================
#
# The chess system follows a clean architecture pattern with these components:
#
# 1. GAME MANAGER (GameManager)
#    - Pure game state management logic
#    - Manages board state, piece selection, turn management
#    - No UI dependencies - pure logic
#    - Emits signals for state changes
#
# 2. BOARD RENDERER (BoardRenderer) 
#    - Visual board representation and tile management
#    - Handles tile highlighting, colors, and visual feedback
#    - Manages tile references and positioning
#    - Separated from game logic
#
# 3. PIECE SPAWNER (PieceSpawner)
#    - Creates and initializes all chess pieces
#    - Handles piece setup and board population
#    - Integrates with GameManager for state tracking
#
# 4. CURSORS (White/Black Cursor)
#    - Player input handling and cursor management
#    - Movement, selection, and hover logic
#    - Turn validation and visual feedback
#
# 5. BOARD (This class)
#    - Main coordinator and system manager
#    - Initializes all subsystems
#    - Handles signal routing and system communication
#    - Provides public API for accessing systems
#
# =============================================================================
# IMPORTANT ENUMS AND CONSTANTS
# =============================================================================
#
# Game States (ChessConstants.GameState):
#   - WHITE_TURN: White player's turn
#   - BLACK_TURN: Black player's turn  

#
# Team Colors (ChessConstants.TeamColor):
#   - WHITE = 0
#   - BLACK = 1
#
# Player IDs (ChessConstants.PlayerId):
#   - WHITE_PLAYER = 1
#   - BLACK_PLAYER = 2
#
# Board Constants:
#   - BOARD_SIZE = 8 (8x8 chess board)
#   - TILE_SIZE = 24 (pixels per tile)
#
# =============================================================================
# HOW TO ACCESS GAME SYSTEMS
# =============================================================================
#
# From any script that has access to the Board node:
#
# var board = get_node("/path/to/Board")
# var game_manager = board.get_game_manager()
# var board_renderer = board.get_board_renderer()
# var piece_spawner = board.get_piece_spawner()
#
# =============================================================================
# COMMON OPERATIONS
# =============================================================================
#
# Check current game state:
#   var current_state = game_manager.current_game_state
#   var current_turn = game_manager.get_current_turn()    Whose turn it is
#
# Check if a piece is selected:
#   if game_manager.selected_piece != null:
#       print("Piece selected: ", game_manager.selected_piece.name)
#
# Get piece at position:
#   var piece = game_manager.get_piece_at_position(Vector2i(x, y))
#
# Highlight a tile:
#   board_renderer.highlight_tile(Vector2i(x, y), Color.GREEN)
#
# Reset tile color:
#   board_renderer.reset_tile_color(Vector2i(x, y))
#
# Check if player can act:
#   var can_act = game_manager.can_player_act(ChessConstants.PlayerId.WHITE_PLAYER)
#
# =============================================================================
# SIGNAL SYSTEM
# =============================================================================
#
# GameManager emits these signals:
#   - game_state_changed(new_state): When game state changes
#   - piece_selected(piece): When a piece is selected
#   - piece_deselected(): When a piece is deselected
#   - turn_switched(new_team): When turn switches between players
#
# Connect to signals for reactive programming:
#   game_manager.piece_selected.connect(_on_piece_selected)
#   game_manager.turn_switched.connect(_on_turn_switched)
#
# =============================================================================
# DEBUGGING TIPS
# =============================================================================
#
# 1. Check game state: print(game_manager.current_game_state)
# 2. Check selected piece: print(game_manager.selected_piece)
# 3. Check current team: print(game_manager.get_current_team())
# 4. Check piece at position: print(game_manager.get_piece_at_position(pos))
# 5. Check if position is valid: print(game_manager.is_valid_position(pos)) Meaning its an actually on the grid
#
# =============================================================================
# SCENE STRUCTURE REQUIREMENTS
# =============================================================================
#
# The Board scene must have these child nodes:
#   - WhiteCursor: Cursor for white player
#   - BlackCursor: Cursor for black player  
#   - BoardRenderer: Visual board management
#    -> TilesContainer: Container for the tiles
#   - Camera2D: Game camera
#
# =============================================================================

# Scene references - These must exist in the scene tree
@onready var white_cursor: Node2D = $WhiteCursor
@onready var black_cursor: Node2D = $BlackCursor
@onready var board_renderer: BoardRenderer = $BoardRenderer
@onready var camera_2d: Camera2D = $Camera2D

# Export properties - Set these in the editor
@export var piece_sprite_sheet: Texture

# Core systems - Initialized at runtime
var game_manager: GameManager
var piece_spawner: PieceSpawner
var scene_manager: SceneManager

# Initialization of all systems
func _ready():
	# Dont Change order who knows what might happen lol
	initialize_systems()
	setup_camera()
	setup_cursors()
	spawn_initial_pieces()
	connect_signals()

func initialize_systems():
	# Initialize game manager (handles all game logic)
	game_manager = GameManager.new()
	# Initialize piece spawner (creates chess pieces)
	piece_spawner = PieceSpawner.new()
	add_child(piece_spawner)
	piece_spawner.setup(game_manager, self, piece_sprite_sheet)

func setup_camera():
	#Set up camera in middle
	var board_center = board_renderer.get_board_center()
	camera_2d.position = board_center

func setup_cursors():
	var board_center = board_renderer.get_board_center()
	
	
	# Setup white cursor (Player 1)
	white_cursor.cursor_pos = board_center
	white_cursor.setup(game_manager, board_renderer)
	
	# Setup black cursor (Player 2)
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
	game_manager.piece_moved.connect(_on_piece_moved)
	game_manager.initiate_duel.connect(_on_initiate_duel)
	SceneManager.duel_ended.connect(_on_duel_ended)
#These are all the signal handlers

func _on_game_state_changed(new_state: ChessConstants.GameState):
	#Called when the game state changes (turn switch, game over, etc.)
	
	print("Game state changed to: ", new_state)
	# Add any global game state handling here

func _on_piece_selected(piece: Piece):
	#Called when a player selects a chess piece.
	for move in piece.get_valid_moves(game_manager):
		if game_manager.is_valid_move(piece, move):
			if(game_manager.get_piece_at_position(move) == null):
				board_renderer.show_move_icon(move)
		else:
			board_renderer.highlight_tile(move, Color.RED)
	print("Piece selected: ", piece.name)
	# Add any piece selection handling here

func _on_piece_deselected():
	#Called when a piece is deselected (cancel or move).
	board_renderer.clear_move_icons()
	print("Piece deselected")
	# Add any piece deselection handling here

func _on_turn_switched(new_team: ChessConstants.TeamColor):
	#Called when the turn switches between players.

	print("Turn switched to: ", "White" if new_team == ChessConstants.TeamColor.WHITE else "Black")

func _on_piece_moved(piece: Piece, from_pos: Vector2i, to_pos: Vector2i):
	#print("Piece moved: ", piece.name, " from ", from_pos, " to ", to_pos)
	board_renderer.reset_all_tiles()
	board_renderer.clear_move_icons()

func _on_initiate_duel(attacker: Piece, defender: Piece, defecit: int):
	print("Initiate duel: ", attacker.name, " vs ", defender.name, " with defecit of ", defecit)
	board_renderer.reset_all_tiles()
	#input if defender or attacker won in terminal
	
	SceneManager.transition_to_duel(attacker, defender, defecit)
	

func _on_duel_ended(winner: Piece, looser: Piece):
	game_manager.handle_duel_result(winner, looser)
	looser.get_parent().remove_child(looser)
	game_manager.add_captured_piece(looser)
	game_manager.update_points()
	board_renderer.reset_all_tiles()
	game_manager.switch_turn()
	
func get_game_manager() -> GameManager:
	#Returns the GameManager instance for accessing game state and logic.

	return game_manager

func get_board_renderer() -> BoardRenderer:
	#Returns the BoardRenderer instance for visual board operations.

	return board_renderer

func get_piece_spawner() -> PieceSpawner:
	#Returns the PieceSpawner instance for piece creation operations.

	return piece_spawner
