extends Piece
class_name King

func get_sprite_column() -> int:
	return 1

func get_valid_moves(game_manager: GameManager) -> Array:
	var moves: Array = []

	# One step in any direction
	var directions = [
		Vector2i(1, 1), Vector2i(1, 0), Vector2i(1, -1),
		Vector2i(0, 1), Vector2i(0, -1),
		Vector2i(-1, 1), Vector2i(-1, 0), Vector2i(-1, -1),
	]
	
	for dir in directions:
		var target = board_position + dir
		if game_manager.is_valid_position(target):
			if game_manager.is_empty(target) or game_manager.is_enemy(target, team):
				moves.append(target)
	
	# Castling moves
	if move_count == 0: # check if the king has moved
		# King side castling
		var rook_king_side = game_manager.get_piece_at_position(Vector2i(7, board_position.y))
		if rook_king_side != null and rook_king_side.move_count == 0: # check if the king side rook has moved
			# Check if squares between king and rook are empty
			if game_manager.is_empty(Vector2i(board_position.x + 2, board_position.y)) and game_manager.is_empty(Vector2i(board_position.x + 1, board_position.y)):
				# Check if the king is in check or go through check or would be in check after the move
				if not (
					game_manager.is_king_in_check(team)
					or game_manager.is_king_in_check_after_move(team, Vector2i(board_position.x + 1, board_position.y))
					or game_manager.is_king_in_check_after_move(team, Vector2i(board_position.x + 2, board_position.y))
				):
					moves.append(Vector2i(board_position.x + 2, board_position.y))
		# Queen side castling
		var rook_queen_side = game_manager.get_piece_at_position(Vector2i(0, board_position.y))
		if rook_queen_side != null and rook_queen_side.move_count == 0: # check if the queen side rook has moved
			if game_manager.is_empty(Vector2i(board_position.x - 3, board_position.y)) and game_manager.is_empty(Vector2i(board_position.x - 2, board_position.y)) and game_manager.is_empty(Vector2i(board_position.x - 1, board_position.y)):
				if not (
					game_manager.is_king_in_check(team)
					or game_manager.is_king_in_check_after_move(team, Vector2i(board_position.x - 1, board_position.y))
					or game_manager.is_king_in_check_after_move(team, Vector2i(board_position.x - 2, board_position.y))
				):
					moves.append(Vector2i(board_position.x - 2, board_position.y))

	return moves

# Castling does not attack the king, so no need to detect check
func get_opponent_valid_moves(game_manager: GameManager) -> Array:
	var moves: Array = []

	# One step in any direction
	var directions = [
		Vector2i(1, 1), Vector2i(1, 0), Vector2i(1, -1),
		Vector2i(0, 1), Vector2i(0, -1),
		Vector2i(-1, 1), Vector2i(-1, 0), Vector2i(-1, -1),
	]
	
	for dir in directions:
		var target = board_position + dir
		if game_manager.is_valid_position(target):
			if game_manager.is_empty(target) or game_manager.is_enemy(target, team):
				moves.append(target)

	return moves
