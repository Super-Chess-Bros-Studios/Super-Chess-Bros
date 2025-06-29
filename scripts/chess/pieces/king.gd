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
	return moves
