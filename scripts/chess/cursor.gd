extends Node2D

# Which player this cursor belongs to (WHITE_PLAYER = 1, BLACK_PLAYER = 2)
@export var player_id: ChessConstants.PlayerId = ChessConstants.PlayerId.WHITE_PLAYER
@export var move_speed := 80.0

# Cursor position in pixels
var cursor_pos := Vector2.ZERO
# Total board size in pixels
var board_size_pixels := Vector2.ZERO
# Size of cursor sprite
var cursor_size := Vector2.ZERO
# Last tile position the cursor was hovering over
var last_hovered_tile := Vector2i(-1, -1)

# Movement state for smooth movement
var movement_vector := Vector2.ZERO

@onready var sprite: Sprite2D = $Sprite2D

# References to main systems
var game_manager: GameManager
var board_renderer: BoardRenderer
var input_manager: InputManager

func _ready():
	# Calculate board dimensions and set initial cursor position
	board_size_pixels = Vector2(ChessConstants.BOARD_SIZE * ChessConstants.TILE_SIZE, ChessConstants.BOARD_SIZE * ChessConstants.TILE_SIZE)
	cursor_pos = Vector2(ChessConstants.BOARD_SIZE / 2 * ChessConstants.TILE_SIZE, ChessConstants.BOARD_SIZE / 2 * ChessConstants.TILE_SIZE)
	cursor_size = Vector2(ChessConstants.TILE_SIZE, ChessConstants.TILE_SIZE)
	
	# Make sure sprite is visible
	if sprite:
		sprite.visible = true
	
	# Set cursor colors - red for white player, yellow for black player
	if player_id == ChessConstants.PlayerId.WHITE_PLAYER:
		sprite.modulate = Color(1.0, 0.0, 0.0)  # Bright red
	else:
		sprite.modulate = Color(1.0, 1.0, 0.0)  # Bright yellow

func setup(_game_manager: GameManager, _board_renderer: BoardRenderer, _input_manager: InputManager):
	# Get references to main systems from the board
	game_manager = _game_manager
	board_renderer = _board_renderer
	input_manager = _input_manager

func _process(delta):
	# Apply smooth movement using stored movement vector
	if movement_vector.length() > 0.1:
		cursor_pos += movement_vector.normalized() * move_speed * delta
	
	# Keep cursor within board boundaries
	cursor_pos.x = clamp(cursor_pos.x, 0, board_size_pixels.x - cursor_size.x)
	cursor_pos.y = clamp(cursor_pos.y, 0, board_size_pixels.y - cursor_size.y)
	
	position = cursor_pos
	update_hover()

func _input(event):
	if not input_manager:
		print("No input manager found")
		return
	
	# Update movement vector for smooth movement (continuous)
	update_movement_vector(event)
	handle_selection_input(event)

func update_hover():
	# Convert pixel position to tile coordinates
	var tile_x = int(floor(cursor_pos.x / ChessConstants.TILE_SIZE))
	var tile_y = int(floor(cursor_pos.y / ChessConstants.TILE_SIZE))
	var tile_pos = Vector2i(tile_x, tile_y)
	
	# Only update hover if tile changed and it's this player's turn
	if tile_pos != last_hovered_tile and game_manager.can_player_act(player_id):
		handle_hover_change(last_hovered_tile, tile_pos)
		last_hovered_tile = tile_pos

func handle_hover_change(old_tile_pos: Vector2i, new_tile_pos: Vector2i):
	if not game_manager or not board_renderer:
		return
	
	# Clear previous tile highlight (unless it's the selected piece)
	if old_tile_pos != Vector2i(-1, -1):
		if game_manager.selected_piece == null or old_tile_pos != game_manager.selected_piece.board_position:
			board_renderer.reset_tile_color(old_tile_pos)
	
	# Set new tile highlight
	var piece_at_tile = game_manager.get_piece_at_position(new_tile_pos)
	var selected_piece = game_manager.selected_piece
	var current_turn = game_manager.get_current_turn()
	
	if selected_piece == null or (piece_at_tile != selected_piece):
		# Use team color for hover (blue for white, dark blue for black)
		var hover_color = ChessConstants.HOVER_COLORS[current_turn]
		board_renderer.highlight_tile(new_tile_pos, hover_color)
	else:
		# Keep selected piece tile green
		board_renderer.highlight_tile(new_tile_pos, ChessConstants.SELECTION_COLOR)

func handle_selection_input(event):
	if not game_manager:
		return
		
	# Handle accept (select piece/move) and cancel (deselect) inputs
	if event.is_action_pressed(get_action("accept", player_id, event)):
		print("Accept for player ", player_id)
		handle_accept_input()
	
	if event.is_action_pressed(get_action("cancel", player_id, event)):
		handle_cancel_input()

func handle_accept_input():
	# Only allow input if it's this player's turn
	if not game_manager.can_player_act(player_id):
		print("Cannot accept for player ", player_id)
		return
	
	var tile_pos = get_current_tile_pos()
	var piece = game_manager.get_piece_at_position(tile_pos)
	
	# If no piece selected and we're on a piece of our color - select it
	if game_manager.selected_piece == null and piece != null:
		if game_manager.select_piece(piece):
			board_renderer.highlight_tile(tile_pos, ChessConstants.SELECTION_COLOR)
		return
	
	# DEMONSTRAION PIECE MOVEMENT
	if game_manager.selected_piece != null:
		var selected_piece = game_manager.selected_piece
		var selected_pos = selected_piece.board_position
		if tile_pos == selected_pos:
			return
		
		game_manager.piece_moved.emit(selected_piece,selected_pos,tile_pos)

func handle_cancel_input():
	# Only allow cancel if it's this player's turn
	if not game_manager.can_player_act(player_id):
		return
	
	# Deselect piece and reset tile color
	if game_manager.selected_piece != null:
		var selected_pos = game_manager.selected_piece.board_position
		board_renderer.reset_tile_color(selected_pos)
		game_manager.deselect_piece()

func update_movement_vector(event):
	# Update movement vector based on current input state
	if not input_manager:
		movement_vector = Vector2.ZERO
		return
	
	var x_axis := Input.get_action_strength(get_action("right", player_id, event)) - Input.get_action_strength(get_action("left", player_id, event))
	var y_axis := Input.get_action_strength(get_action("down", player_id, event)) - Input.get_action_strength(get_action("up", player_id, event))
	
	movement_vector = Vector2(x_axis, y_axis)

func get_current_tile_pos() -> Vector2i:
	# Get the tile position the cursor is currently hovering over
	return last_hovered_tile

func get_action(action_base: String, player_id: int, event) -> String:
	return input_manager.get_action(action_base, player_id, event)
