extends Node2D

# Which player this cursor belongs to (WHITE_PLAYER = 1, BLACK_PLAYER = 2)
@export var player_id: ChessConstants.PlayerId = ChessConstants.PlayerId.WHITE_PLAYER
@export var move_speed := 150.0

# Cursor position in pixels
var cursor_pos := Vector2.ZERO
# Total board size in pixels
var board_size_pixels := Vector2.ZERO
# Size of cursor sprite
var cursor_size := Vector2.ZERO
# Last tile position the cursor was hovering over
var last_hovered_tile := Vector2i(-1, -1)

@onready var sprite: Sprite2D = $Sprite2D

# References to main systems
var game_manager: GameManager
var board_renderer: BoardRenderer

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

func setup(_game_manager: GameManager, _board_renderer: BoardRenderer):
	# Get references to main systems from the board
	game_manager = _game_manager
	board_renderer = _board_renderer

func _process(delta):
	handle_input(delta)
	handle_selection_input()
	
	# Keep cursor within board boundaries
	cursor_pos.x = clamp(cursor_pos.x, 0, board_size_pixels.x - cursor_size.x)
	cursor_pos.y = clamp(cursor_pos.y, 0, board_size_pixels.y - cursor_size.y)
	
	position = cursor_pos
	update_hover()

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

func handle_selection_input():
	if not game_manager:
		return
		
	# Handle accept (select piece/move) and cancel (deselect) inputs
	if Input.is_action_just_pressed(get_action("accept")):
		handle_accept_input()
	
	if Input.is_action_just_pressed(get_action("cancel")):
		handle_cancel_input()

func handle_accept_input():
	# Only allow input if it's this player's turn
	if not game_manager.can_player_act(player_id):
		return
	
	var tile_pos = get_current_tile_pos()
	var piece = game_manager.get_piece_at_position(tile_pos)
	
	# If no piece selected and we're on a piece of our color - select it
	if game_manager.selected_piece == null and piece != null:
		if game_manager.select_piece(piece):
			board_renderer.highlight_tile(tile_pos, ChessConstants.SELECTION_COLOR)
		return
	
	if game_manager.selected_piece != null:
		var selected_piece = game_manager.selected_piece
		var selected_pos = selected_piece.board_position
		if tile_pos == selected_pos:
			handle_cancel_input()
			return
		
		# Try to move the piece using the GameManager
		if game_manager.move_piece(selected_piece, tile_pos):
			# Move was successful, tile colors will be reseted by the move_piece function
			pass
		else:
			print("Invalid move!")

func handle_cancel_input():
	# Only allow cancel if it's this player's turn
	if not game_manager.can_player_act(player_id):
		return
	
	# Deselect piece and reset tile color
	if game_manager.selected_piece != null:
		var selected_pos = game_manager.selected_piece.board_position
		board_renderer.reset_tile_color(selected_pos)
		game_manager.deselect_piece()
		board_renderer.reset_all_tiles()

func handle_input(delta):
	# Handle movement input (WASD or arrow keys)
	var x_axis := Input.get_action_strength(get_action("right")) - Input.get_action_strength(get_action("left"))
	var y_axis := Input.get_action_strength(get_action("down")) - Input.get_action_strength(get_action("up"))
	var input_vec = Vector2(x_axis, y_axis)
	
	if input_vec.length() < 0.1:
		return  # deadzone
	
	cursor_pos += input_vec.normalized() * move_speed * delta

func get_action(base_action: String) -> String:
	# Convert base action to player-specific action (e.g., "accept" -> "accept_1" for white player)
	var player_suffix = "1" #if player_id == ChessConstants.PlayerId.WHITE_PLAYER else "2"
	return base_action + "_" + player_suffix

func get_current_tile_pos() -> Vector2i:
	# Get the tile position the cursor is currently hovering over
	return last_hovered_tile
