extends Node2D

@export var player_id: ChessConstants.PlayerId = ChessConstants.PlayerId.WHITE_PLAYER
@export var move_speed := 80.0

var cursor_pos := Vector2.ZERO
var board_size_pixels := Vector2.ZERO
var cursor_size := Vector2.ZERO
var last_hovered_tile := Vector2i(-1, -1)

@onready var sprite: Sprite2D = $Sprite2D

# References
var game_manager: GameManager
var board_renderer: BoardRenderer

func _ready():
	board_size_pixels = Vector2(ChessConstants.BOARD_SIZE * ChessConstants.TILE_SIZE, ChessConstants.BOARD_SIZE * ChessConstants.TILE_SIZE)
	cursor_pos = Vector2(ChessConstants.BOARD_SIZE / 2 * ChessConstants.TILE_SIZE, ChessConstants.BOARD_SIZE / 2 * ChessConstants.TILE_SIZE)
	cursor_size = Vector2(ChessConstants.TILE_SIZE, ChessConstants.TILE_SIZE)
	
	# Make sure sprite is visible
	if sprite:
		sprite.visible = true
	
	# Set color of Cursors
	if player_id == ChessConstants.PlayerId.WHITE_PLAYER:
		sprite.modulate = Color(1.0, 0.0, 0.0)  # Bright red
	else:
		sprite.modulate = Color(1.0, 1.0, 0.0)  # Bright yellow

func setup(_game_manager: GameManager, _board_renderer: BoardRenderer):
	game_manager = _game_manager
	board_renderer = _board_renderer

func _process(delta):
	handle_input(delta)
	handle_selection_input()
	
	# Clamp cursor within board bounds
	cursor_pos.x = clamp(cursor_pos.x, 0, board_size_pixels.x - cursor_size.x)
	cursor_pos.y = clamp(cursor_pos.y, 0, board_size_pixels.y - cursor_size.y)
	
	position = cursor_pos
	update_hover()

func update_hover():
	# Convert the cursor's pixel position to tile coordinates
	var tile_x = int(floor(cursor_pos.x / ChessConstants.TILE_SIZE))
	var tile_y = int(floor(cursor_pos.y / ChessConstants.TILE_SIZE))
	var tile_pos = Vector2i(tile_x, tile_y)
	
	# Only update hover if the tile changed
	if tile_pos != last_hovered_tile:
		handle_hover_change(last_hovered_tile, tile_pos)
		last_hovered_tile = tile_pos

func handle_hover_change(old_tile_pos: Vector2i, new_tile_pos: Vector2i):
	if not game_manager or not board_renderer:
		return
	
	# Clear previous highlight if it exists
	if old_tile_pos != Vector2i(-1, -1):
		# Only remove if not selected tile
		if game_manager.selected_piece == null or old_tile_pos != game_manager.selected_piece.board_position:
			board_renderer.reset_tile_color(old_tile_pos)
	
	# Set new highlight
	var piece_at_tile = game_manager.get_piece_at_position(new_tile_pos)
	var selected_piece = game_manager.selected_piece
	var current_team = game_manager.get_current_team()
	
	if selected_piece == null or (piece_at_tile != selected_piece):
		# Use appropriate color based on current turn
		var hover_color = ChessConstants.HOVER_COLORS[current_team]
		board_renderer.highlight_tile(new_tile_pos, hover_color)
	else:
		# Selected piece tile stays green
		board_renderer.highlight_tile(new_tile_pos, ChessConstants.SELECTION_COLOR)

func handle_selection_input():
	if not game_manager:
		return
		
	# Handle accept/cancel inputs for this cursor
	if Input.is_action_just_pressed(get_action("accept")):
		handle_accept_input()
	
	if Input.is_action_just_pressed(get_action("cancel")):
		handle_cancel_input()

func handle_accept_input():
	if not game_manager.can_player_act(player_id):
		return
	
	var tile_pos = get_current_tile_pos()
	var piece = game_manager.get_piece_at_position(tile_pos)
	
	# If no piece is selected and we're on a piece of our color
	if game_manager.selected_piece == null and piece != null:
		if game_manager.select_piece(piece):
			board_renderer.highlight_tile(tile_pos, ChessConstants.SELECTION_COLOR)
		return
	
	if game_manager.selected_piece != null:
		# Movement logic will go here
		game_manager.switch_turn()
		game_manager.deselect_piece()

func handle_cancel_input():
	if not game_manager.can_player_act(player_id):
		return
	
	if game_manager.selected_piece != null:
		var selected_pos = game_manager.selected_piece.board_position
		board_renderer.reset_tile_color(selected_pos)
		game_manager.deselect_piece()

func handle_input(delta):
	var x_axis := Input.get_action_strength(get_action("right")) - Input.get_action_strength(get_action("left"))
	var y_axis := Input.get_action_strength(get_action("down")) - Input.get_action_strength(get_action("up"))
	var input_vec = Vector2(x_axis, y_axis)
	
	if input_vec.length() < 0.1:
		return  # deadzone
	
	cursor_pos += input_vec.normalized() * move_speed * delta

func get_action(base_action: String) -> String:
	var player_suffix = "1" if player_id == ChessConstants.PlayerId.WHITE_PLAYER else "2"
	return base_action + "_" + player_suffix

func get_current_tile_pos() -> Vector2i:
	return last_hovered_tile

func update_hover_after_turn_switch():
	if last_hovered_tile != Vector2i(-1, -1):
		handle_hover_change(Vector2i(-1, -1), last_hovered_tile)
