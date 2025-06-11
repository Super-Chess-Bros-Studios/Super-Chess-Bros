extends Node2D

@export var piece_type: String  # e.g. "bishop", "king", etc.
@export var is_white: bool  # true for white, false for black
@export var board_position: Vector2i  # grid position on the board (0-7,0-7)
@export var point_value: int # respective point value of each piece

var sprite_sheet: Texture  # assign once from a shared resource
var sprite: Sprite2D

# Mapping piece types to column index in sprite sheet
const PIECE_ORDER = {
	"bishop": 0,
	"king": 1,
	"knight": 2,
	"pawn": 3,
	"queen": 4,
	"rook": 5,
}

func _ready():
	sprite = $Sprite2D
	if sprite_sheet:
		update_sprite_region()

func update_sprite_region():
	var col = PIECE_ORDER.get(piece_type, 0)
	var row = 0 if not is_white else 1  # black = 0, white = 1

	var padding = 1  # 1 pixel padding between frames

	var frame_width = (sprite_sheet.get_width() - padding * (6 - 1)) / 6
	var frame_height = (sprite_sheet.get_height() - padding * (2 - 1)) / 2

	var x = col * (frame_width + padding)
	var y = row * (frame_height + padding)

	sprite.texture = sprite_sheet
	sprite.region_enabled = true
	sprite.region_rect = Rect2(x, y, frame_width, frame_height)

# IMPORTANT FUNCTION: This is how you set the position of piece 
func set_board_position(pos: Vector2i, tile_size: int = 24):
	board_position = pos
	position = Vector2(pos.x * tile_size + tile_size/2, pos.y * tile_size + tile_size/2)
