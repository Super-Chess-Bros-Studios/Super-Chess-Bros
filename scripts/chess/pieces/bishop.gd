extends Piece
class_name Bishop

func get_sprite_column() -> int:
	return 0

func get_valid_moves(game_manager: GameManager) -> Array:
	var moves: Array = []

	# Diagonal movements
	var directions = [
		Vector2i(1, 1), # right down
		Vector2i(1, -1), # right up
		Vector2i(-1, 1), # left down
		Vector2i(-1, -1), # left up
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
