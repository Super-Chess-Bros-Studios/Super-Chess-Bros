extends Sprite2D

const BOARD_SIZE = 8
const CELL_WIDTH = 18

#Placeholder for each piece sprite
const TEXTURE_HOLDER = preload("res://scenes/texture_holder.tscn")

#Black Pieces
const BLACK_BISHOP = preload("res://assets/sprites/chess_pieces/black_bishop.png")
const BLACK_KING = preload("res://assets/sprites/chess_pieces/black_king.png")
const BLACK_PAWN = preload("res://assets/sprites/chess_pieces/black_pawn.png")
const BLACK_QUEEN = preload("res://assets/sprites/chess_pieces/black_queen.png")
const BLACK_ROOK = preload("res://assets/sprites/chess_pieces/black_rook.png")
const BLACK_KNIGHT = preload("res://assets/sprites/chess_pieces/black_knight.png")
const TURN_BLACK = preload("res://assets/sprites/chess_pieces/turn-black.png")

#White Pieces
const WHITE_BISHOP = preload("res://assets/sprites/chess_pieces/white_bishop.png")
const WHITE_KING = preload("res://assets/sprites/chess_pieces/white_king.png")
const WHITE_KNIGHT = preload("res://assets/sprites/chess_pieces/white_knight.png")
const WHITE_QUEEN = preload("res://assets/sprites/chess_pieces/white_queen.png")
const WHITE_ROOK = preload("res://assets/sprites/chess_pieces/white_rook.png")
const WHITE_PAWN = preload("res://assets/sprites/chess_pieces/white_pawn.png")
const TURN_WHITE = preload("res://assets/sprites/chess_pieces/turn-white.png")

@onready var pieces: Node2D = $Pieces
@onready var dots: Node2D = $Dots
@onready var turn: Sprite2D = $Turn

#Variables
# num will represent each piece and if it is - it means it is black
# 0 = empty, 1 = pawn, 2 = knight, 3 = bishop, 4 = rook, 5 = queen, 6 = king
var board: Array
var white: bool
var state : bool
var moves = []
var selected_piece : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	board.append([4,2,3,5,6,3,2,4])
	board.append([1,1,1,1,1,1,1,1])
	board.append([0,0,0,0,0,0,0,0])
	board.append([0,0,0,0,0,0,0,0])
	board.append([0,0,0,0,0,0,0,0])
	board.append([0,0,0,0,0,0,0,0])
	board.append([-1,-1,-1,-1,-1,-1,-1,-1])
	board.append([-4,-2,-3,-5,-6,-3,-2,-4])
	
	display_board()
	
func display_board():
	for i in BOARD_SIZE:
		for j in BOARD_SIZE:
			var holder = TEXTURE_HOLDER.instantiate()
			pieces.add_child(holder)
			holder.global_position = Vector2(j * CELL_WIDTH + (CELL_WIDTH/2), -i * CELL_WIDTH - (CELL_WIDTH/2))
			
			match board[i][j]:
				-6: holder.texture = BLACK_KING
				-5: holder.texture = BLACK_QUEEN
				-4: holder.texture = BLACK_ROOK
				-3: holder.texture = BLACK_BISHOP
				-2: holder.texture = BLACK_KNIGHT
				-1: holder.texture = BLACK_PAWN
				0: holder.texture = null
				6: holder.texture = WHITE_KING
				5: holder.texture = WHITE_QUEEN
				4: holder.texture = WHITE_ROOK
				3: holder.texture = WHITE_BISHOP
				2: holder.texture = WHITE_KNIGHT
				1: holder.texture = WHITE_PAWN
	
