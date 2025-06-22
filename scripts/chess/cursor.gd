extends Node2D

@export var player_id: int = 1  # Exposed variable for player ID
@export var move_speed := 80.0

var tile_size := 24
const BOARD_SIZE := 8
var cursor_pos := Vector2.ZERO
var board_size_pixels := Vector2.ZERO
var cursor_size := Vector2.ZERO
var last_hovered_tile := Vector2i(-1, -1)  # Track last hovered tile

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	
	board_size_pixels = Vector2(BOARD_SIZE * tile_size, BOARD_SIZE * tile_size)
	cursor_pos = Vector2(BOARD_SIZE / 2 * tile_size, BOARD_SIZE / 2 * tile_size)
	cursor_size = Vector2(tile_size, tile_size)
	
	# Make sure sprite is visible
	if sprite:
		sprite.visible = true
	
	# Set color of Cursors
	if player_id == 1:
		sprite.modulate = Color(1.0, 0.0, 0.0)  # Bright red
	else:
		sprite.modulate = Color(1.0, 1.0, 0.0)  # Bright yellow

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
	var tile_x = int(floor(cursor_pos.x / tile_size))
	var tile_y = int(floor(cursor_pos.y / tile_size))
	var tile_pos = Vector2i(tile_x, tile_y)
	
	# Only update hover if the tile changed
	if tile_pos != last_hovered_tile:
		handle_hover_change(last_hovered_tile, tile_pos)
		last_hovered_tile = tile_pos

func handle_hover_change(old_tile_pos: Vector2i, new_tile_pos: Vector2i):
	var board = get_parent()
	
	# Clear previous highlight if it exists
	if old_tile_pos != Vector2i(-1, -1):
		var prev_tile = board.get_tile_at_position(old_tile_pos)
		if prev_tile:
			# Only remove if not selected tile
			var selected_piece = board.selected_piece
			if selected_piece == null or old_tile_pos != selected_piece.board_position:
				prev_tile.reset_color()
	
	# Set new highlight
	var tile = board.get_tile_at_position(new_tile_pos)
	if tile:
		var board_state = board.board_state
		var piece_at_tile = board_state[new_tile_pos.y][new_tile_pos.x]
		var selected_piece = board.selected_piece
		var current_turn = board.current_turn
		var turn_colors = board.turn_colors
		
		if selected_piece == null or (piece_at_tile != selected_piece):
			# Use appropriate color based on current turn
			tile.highlight(turn_colors[current_turn])
		else:
			# Selected piece tile stays green
			tile.highlight(Color.GREEN)

func handle_selection_input():
	# Handle accept/cancel inputs for this cursor
	if Input.is_action_just_pressed(get_action("accept")):
		if get_parent().has_method("handle_tile_click"):
			get_parent().handle_tile_click(player_id)
	
	if Input.is_action_just_pressed(get_action("cancel")):
		if get_parent().has_method("handle_cancel_selection"):
			get_parent().handle_cancel_selection(player_id)

func handle_input(delta):
	var x_axis := Input.get_action_strength(get_action("right")) - Input.get_action_strength(get_action("left"))
	var y_axis := Input.get_action_strength(get_action("down")) - Input.get_action_strength(get_action("up"))
	var input_vec = Vector2(x_axis, y_axis)
	
	if input_vec.length() < 0.1:
		return  # deadzone
	
	cursor_pos += input_vec.normalized() * move_speed * delta

# Function to get action names with player_id suffix
func get_action(base_action: String) -> String:
	return base_action + "_" + str(player_id)

func get_current_tile_pos() -> Vector2i:
	return last_hovered_tile
