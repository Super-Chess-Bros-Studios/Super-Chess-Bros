extends Piece
class_name Knight

func get_sprite_column() -> int:
	return 2

func get_valid_moves(game_manager: GameManager) -> Array:
	var moves: Array = []

	# L shape movements
	var directions = [
		Vector2i(1, 2), Vector2i(2, 1),
		Vector2i(2, -1), Vector2i(1, -2),
		Vector2i(-1, -2), Vector2i(-2, -1),
		Vector2i(-2, 1), Vector2i(-1, 2),
	]

	# Move if target is valid and empty or enemy
	for dir in directions:
		var target = board_position + dir
		if game_manager.is_valid_position(target):
			if game_manager.is_empty(target) or game_manager.is_enemy(target, team):
				moves.append(target)
	return moves

# This is used to check if the king is in check after a move
func get_opponent_valid_moves(game_manager: GameManager) -> Array:
	var moves: Array = []

	# L shape movements
	var directions = [
		Vector2i(1, 2), Vector2i(2, 1),
		Vector2i(2, -1), Vector2i(1, -2),
		Vector2i(-1, -2), Vector2i(-2, -1),
		Vector2i(-2, 1), Vector2i(-1, 2),
	]

	# Move if target is valid and empty or enemy
	for dir in directions:
		var target = board_position + dir
		if game_manager.is_valid_position(target):
			if game_manager.is_empty(target) or game_manager.is_enemy(target, team):
				moves.append(target)
	return moves
