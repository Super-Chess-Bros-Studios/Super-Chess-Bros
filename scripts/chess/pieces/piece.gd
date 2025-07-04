# Piece.gd This is the base class for all pieces
extends Node2D
class_name Piece

var team # Enum from board.gd, white = 0, black = 1
var board_position: Vector2i
var point_value: int
var sprite_sheet: Texture
var move_count: int # Track how many times this piece moved (for castling and en passant)

@onready var sprite: Sprite2D = $Sprite2D

# This takes the grid position and sets the pixel position
func set_board_position(pos: Vector2i, tile_size: int = 24):
	board_position = pos
	position = Vector2(pos.x * tile_size + tile_size/2, pos.y * tile_size + tile_size/2)

func setup(_team, _pos: Vector2i, _sheet: Texture, _points: int, tile_size: int):
	team = _team
	point_value = _points
	sprite_sheet = _sheet
	move_count = 0  # Initialize as not moved
	set_board_position(_pos, tile_size)
	update_sprite_region()

# Mark piece as moved (for castling and en passant)
func mark_as_moved():
	move_count += 1 
	print("move count ", move_count) # debug to see if the move count is working.

# Sets sprite based on sprite sheet
func update_sprite_region():
	if sprite_sheet == null:
		print("Sprite sheet is null for piece at ", board_position)
		return

	var col = get_sprite_column()
	var row = 0 if team == 1 else 1 

	var padding = 1
	var frame_width = (sprite_sheet.get_width() - padding * 5) / 6
	var frame_height = (sprite_sheet.get_height() - padding) / 2

	var x = col * (frame_width + padding)
	var y = row * (frame_height + padding)

	sprite.texture = sprite_sheet
	sprite.region_enabled = true
	sprite.region_rect = Rect2(x, y, frame_width, frame_height)

# Sets the column in the sprite sheet
func get_sprite_column() -> int:
	# Override in subclass because each class has a different column in the sprite sheet
	return 0
