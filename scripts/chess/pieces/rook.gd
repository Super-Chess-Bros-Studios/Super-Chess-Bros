extends Piece
class_name Rook

func get_sprite_column() -> int:
	return 5

func get_valid_moves(game_manager: GameManager) -> Array:
	var moves: Array = []

	# Horizontal and vertical movements
	var directions = [
		Vector2i(0, -1), # Up
		Vector2i(0, 1), # Down
		Vector2i(-1, 0), # Left
		Vector2i(1, 0), # Right
	]

	for dir in directions:
		var target = board_position + dir
		while game_manager.is_valid_position(target):
			if game_manager.is_empty(target):
				moves.append(target)
			elif game_manager.is_enemy(target, team):
				moves.append(target)
				break # Can't move past enemy piece
			else:
				break # Can't move past own piece
			target += dir # Keep moving in this direction
	return moves

# This is used to check if the king is in check after a move
func get_opponent_valid_moves(game_manager: GameManager) -> Array:
	var moves: Array = []

	# Horizontal and vertical movements
	var directions = [
		Vector2i(0, -1), # Up
		Vector2i(0, 1), # Down
		Vector2i(-1, 0), # Left
		Vector2i(1, 0), # Right
	]

	for dir in directions:
		var target = board_position + dir
		while game_manager.is_valid_position(target):
			if game_manager.is_empty(target):
				moves.append(target)
			elif game_manager.is_enemy(target, team):
				moves.append(target)
				break # Can't move past enemy piece
			else:
				break # Can't move past own piece
			target += dir # Keep moving in this direction
	return moves
