extends Node2D

@export var player_id: int = 1  # Exposed variable for player ID
@export var move_speed := 80.0

var tile_size := 24
const BOARD_SIZE := 8
var cursor_pos := Vector2.ZERO
var board_size_pixels := Vector2.ZERO
var cursor_size := Vector2.ZERO
var last_hovered_tile := Vector2i(-1, -1)  # Track last hovered tile

func _ready():
	board_size_pixels = Vector2(BOARD_SIZE * tile_size, BOARD_SIZE * tile_size)
	cursor_pos = Vector2(BOARD_SIZE / 2 * tile_size, BOARD_SIZE / 2 * tile_size)
	cursor_size = Vector2(tile_size, tile_size)

func _process(delta):
	handle_input(delta)
	
	# Clamp cursor within board bounds
	cursor_pos.x = clamp(cursor_pos.x, 0, board_size_pixels.x - cursor_size.x)
	cursor_pos.y = clamp(cursor_pos.y, 0, board_size_pixels.y - cursor_size.y)
	
	position = cursor_pos
	update_hover()

func update_hover():
	# Convert the cursor's pixel position to tile coordinates
	var tile_x = int(round(cursor_pos.x / tile_size))
	var tile_y = int(round(cursor_pos.y / tile_size))
	var tile_pos = Vector2i(tile_x, tile_y)
	
	# Only update hover if the tile changed
	if tile_pos != last_hovered_tile:
		last_hovered_tile = tile_pos
		if get_parent().has_method("cursor_hovered"):
			get_parent().cursor_hovered(tile_pos, player_id)

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
