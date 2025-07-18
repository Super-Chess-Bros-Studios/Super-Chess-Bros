extends Piece
class_name Pawn

func get_sprite_column() -> int:
	return 3

func get_valid_moves(game_manager: GameManager) -> Array:
	var moves: Array = []
	var direction := -1 if team == ChessConstants.TeamColor.WHITE else 1 # White go up, black go down
	var start_row := 6 if team == ChessConstants.TeamColor.WHITE else 1 # Set starting row
	
	# Move one step forward
	var one_step := board_position + Vector2i(0, direction)
	if game_manager.is_valid_position(one_step) and game_manager.is_empty(one_step):
		moves.append(one_step)
		
		# Allow two steps from starting position
		var two_step := board_position + Vector2i(0, direction * 2)
		if board_position.y == start_row and game_manager.is_empty(two_step):
			moves.append(two_step)
			
	# When enemy piece is diagonal
	var diag_left := board_position + Vector2i(-1, direction) 
	var diag_right := board_position + Vector2i(1, direction)
	
	if game_manager.is_valid_position(diag_left) and game_manager.is_enemy(diag_left, team):
		moves.append(diag_left)
	if game_manager.is_valid_position(diag_right) and game_manager.is_enemy(diag_right, team):
		moves.append(diag_right)	
	return moves
