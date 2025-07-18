class_name GameManager
extends RefCounted

# Signals for game state changes and piece interactions
signal game_state_changed(new_state: ChessConstants.GameState)
signal piece_selected(piece: Piece)
signal piece_deselected()
signal turn_switched(new_team: InputManager.TeamColor)
signal turn_ended()
signal initiate_duel(attacker: Piece, defender: Piece, defecit: int)
signal ui_update_points(black_points: int, white_points: int)
# Core game state variables
var board_state: Array[Array] = []  # 2D array representing the chess board
var current_game_state: ChessConstants.GameState = ChessConstants.GameState.WHITE_TURN  # Current game state
var selected_piece: Piece = null  # Currently selected piece
# En passant tracking
var en_passant_target: Vector2i = Vector2i(-1, -1) # Initialize en passant target to invalid position
var en_passant_pawn: Piece = null  # Reference to the pawn that can be captured en passant
var en_passant_duel_active: bool = false
var en_passant_landing_square: Vector2i = Vector2i(-1, -1)

var last_moved_piece: Piece = null
# Duel tracking
var duel_attacker: Piece = null
var duel_defender: Piece = null

var white_points: int = 0
var black_points: int = 0

var captured_white_pieces: Array[Piece] = []
var captured_black_pieces: Array[Piece] = []




func _init():
	initialize_board_state()

func initialize_board_state():
	# Create empty 8x8 board state
	board_state.clear()
	for y in range(ChessConstants.BOARD_SIZE):
		var row: Array[Piece] = []
		row.resize(ChessConstants.BOARD_SIZE)
		for x in range(ChessConstants.BOARD_SIZE):
			row[x] = null  # Initialize all positions as empty
		board_state.append(row)

func get_piece_at_position(pos: Vector2i) -> Piece:
	# Return piece at given board position, or null if invalid position
	if is_valid_position(pos):
		return board_state[pos.y][pos.x]
	return null

func set_piece_at_position(pos: Vector2i, piece: Piece):
	# Place piece at given board position if position is valid
	if is_valid_position(pos):
		board_state[pos.y][pos.x] = piece

func is_valid_position(pos: Vector2i) -> bool:
	# Check if position is within board boundaries (0-7 for both x and y)
	return pos.x >= 0 and pos.x < ChessConstants.BOARD_SIZE and pos.y >= 0 and pos.y < ChessConstants.BOARD_SIZE

func can_player_act(team: InputManager.TeamColor) -> bool:
	# Check if given player can act (it's their turn and game isn't over)
	var current_team = ChessConstants.get_team_from_game_state(current_game_state)
	
	return current_team == team and current_game_state != ChessConstants.GameState.GAME_OVER

func select_piece(piece: Piece) -> bool:
	# Select a piece if it belongs to current player's team
	if piece == null:
		return false
	
	var current_team = ChessConstants.get_team_from_game_state(current_game_state)
	if piece.team != current_team:
		return false
	
	selected_piece = piece
	piece_selected.emit(piece)
	return true

func deselect_piece():
	# Clear currently selected piece
	if selected_piece != null:
		selected_piece = null
		piece_deselected.emit()

func switch_turn():
	# Switch between white and black turns
	match current_game_state:
		ChessConstants.GameState.WHITE_TURN:
			current_game_state = ChessConstants.GameState.BLACK_TURN
		ChessConstants.GameState.BLACK_TURN:
			current_game_state = ChessConstants.GameState.WHITE_TURN
	
	var new_team = ChessConstants.get_team_from_game_state(current_game_state)
	game_state_changed.emit(current_game_state)
	turn_switched.emit(new_team)

func get_current_turn() -> InputManager.TeamColor:
	# Get which team's turn it currently is
	return ChessConstants.get_team_from_game_state(current_game_state)

# En passant setter and getter and helper functions
func set_en_passant_target(pos: Vector2i, pawn: Piece):
	# Set the en passant target after a pawn moves two squares
	en_passant_target = pos
	en_passant_pawn = pawn

func clear_en_passant_target():
	# Clear en passant target (called after each move)
	en_passant_target = Vector2i(-1, -1)
	en_passant_pawn = null

func is_en_passant_target(pos: Vector2i) -> bool:
	# Check if a position is the en passant target
	return pos == en_passant_target

func get_en_passant_pawn() -> Piece:
	# Get the pawn that can be captured en passant
	return en_passant_pawn

func is_en_passant_capture(piece: Piece, to_pos: Vector2i) -> bool:
	# Check if this move is an en passant capture
	if not piece is Pawn:
		return false
	
	# En passant capture moves diagonally by 1 square
	var direction = -1 if piece.team == InputManager.TeamColor.WHITE else 1
	var x_diff = abs(to_pos.x - piece.board_position.x)
	var y_diff = direction
	
	# Must move diagonally by 1 square
	if x_diff != 1 or (to_pos.y - piece.board_position.y) != y_diff:
		return false
	
	# Must be capturing the en passant target
	return is_en_passant_target(to_pos)

func perform_en_passant_capture(piece: Piece, to_pos: Vector2i) -> bool:
	# Perform the en passant capture
	var from_pos = piece.board_position
	var captured_pawn = get_en_passant_pawn()
	if captured_pawn == null:
		return false

	# Store en passant duel state
	en_passant_duel_active = true
	en_passant_landing_square = to_pos # The en passant target square (where the pawn should land)

	print("attacker: ", piece)
	print("defender: ", captured_pawn)
	on_initiate_duel(piece, captured_pawn)
	return true


func on_initiate_duel(attacker: Piece, defender: Piece) -> void:
	duel_attacker = attacker
	duel_defender = defender
	var defecit = 0
	if(attacker.point_value < defender.point_value):
		defecit = (defender.point_value - attacker.point_value)*5
		print("Handicap of ", defecit, "% is applied to the defender")
	initiate_duel.emit(attacker, defender, defecit)
	

func move_piece(piece: Piece, to_pos: Vector2i) -> bool:
	# Check if this is a castling move where the king moves 2 squares horizontally. Also check if the move is valid.
	if piece is King and abs(to_pos.x - piece.board_position.x) == 2 and is_valid_move(piece, to_pos):
		return perform_castling(piece, to_pos)
	
	# Validate the move using the piece's get_valid_moves function
	if not is_valid_move(piece, to_pos):
		return false
	#var is_valid = to_pos in piece.get_valid_moves(self)
	#if !is_valid:
		#return false
	var from_pos = piece.board_position
	
	# Handle captures (both regular and en passant)
	var target_piece = null
	var is_en_passant = piece is Pawn and is_en_passant_capture(piece, to_pos)
	
	if is_en_passant:
		target_piece = get_en_passant_pawn()
		print("En passant capture")
	elif is_enemy(to_pos, piece.team):
		target_piece = get_piece_at_position(to_pos)
	
	# If there's a capture, initiate duel
	last_moved_piece = piece
	if target_piece:
		if is_en_passant:
			return perform_en_passant_capture(piece, to_pos)
		else:
			on_initiate_duel(piece, target_piece)
			return false
	# Move piece to new position
	board_state[from_pos.y][from_pos.x] = null  # Remove from old position
	board_state[to_pos.y][to_pos.x] = piece     # Place in new position
	
	piece.set_board_position(to_pos, ChessConstants.TILE_SIZE)
	piece.mark_as_moved()  # Increment move count
	
	# Handle en passant opportunity (if pawn moved two squares)
	if piece is Pawn and abs(to_pos.y - from_pos.y) == 2:
		# create en passant opportunity
		var en_passant_pos = Vector2i(to_pos.x, (from_pos.y + to_pos.y) / 2) # Square that the pawn skips over
		set_en_passant_target(en_passant_pos, piece)
	else:
		#clear en passant opportunity
		clear_en_passant_target() 
	
	# Emit signal for piece movement

	turn_ended.emit()
	
	# Did you check or checkmate oponents king 

	return true

func perform_castling(king: King, to_pos: Vector2i) -> bool:
	var king_y = king.board_position.y
	var from_pos = king.board_position
	var rook_from: Vector2i
	var rook_to: Vector2i
	
	# Determine which rook to move based on castling direction
	if to_pos.x == 6:  # King-side castling
		rook_from = Vector2i(7, king_y)
		rook_to = Vector2i(5, king_y)
	elif to_pos.x == 2:  # Queen-side castling
		rook_from = Vector2i(0, king_y)
		rook_to = Vector2i(3, king_y)
	else:
		return false
	
	# Move king
	board_state[from_pos.y][from_pos.x] = null
	board_state[to_pos.y][to_pos.x] = king
	king.set_board_position(to_pos, ChessConstants.TILE_SIZE)
	king.mark_as_moved()
	
	# Move rook
	var rook = get_piece_at_position(rook_from)
	board_state[rook_from.y][rook_from.x] = null
	board_state[rook_to.y][rook_to.x] = rook
	rook.set_board_position(rook_to, ChessConstants.TILE_SIZE)
	rook.mark_as_moved()
	
	turn_ended.emit()
	
	print("Castling performed")
	return true

func is_valid_move(piece: Piece, to_pos: Vector2i) -> bool:
	# Check if the move is valid for the given piece
	if not is_valid_position(to_pos) or piece == null:
		return false
	
	# Are you moveing to a position that your piece occupies
	if not is_empty(to_pos) and not is_enemy(to_pos, piece.team):
		return false
	
	# Get valid moves for the piece
	var valid_moves = piece.get_valid_moves(self)
	
	if not to_pos in valid_moves:
		return false
	
	#  Simulate the move to check for self-check
	var from_pos = piece.board_position
	var original_piece = board_state[to_pos.y][to_pos.x]
	board_state[from_pos.y][from_pos.x] = null
	board_state[to_pos.y][to_pos.x] = piece
	piece.board_position = to_pos
	
	var in_check = is_king_in_check(piece.team)
	
	# Undo the move
	board_state[from_pos.y][from_pos.x] = piece
	board_state[to_pos.y][to_pos.x] = original_piece
	piece.board_position = from_pos
	
	# not valid if the move puts own king in check
	return not in_check
	
	# Check if the target position is in the valid moves list

	return true

func is_empty(pos: Vector2i) -> bool:
	# Check if position is empty (no piece)
	if not is_valid_position(pos):
		return false
	return board_state[pos.y][pos.x] == null

func is_enemy(pos: Vector2i, team: InputManager.TeamColor) -> bool:
	# Check if position contains an enemy piece
	if not is_valid_position(pos):
		return false
	var piece = board_state[pos.y][pos.x]
	return piece != null and piece.team != team

func is_king_in_check(team: InputManager.TeamColor) -> bool:
	# Find the king for the given team
	var king_pos: Vector2i = Vector2i(-1, -1)
	for y in range(ChessConstants.BOARD_SIZE):
		for x in range(ChessConstants.BOARD_SIZE):
			var piece = board_state[y][x]
			if piece != null and piece.team == team and piece.piece_type == ChessConstants.PIECE_TYPES.king:
				king_pos = Vector2i(x, y)
				break
	
	# error check for king not found
	if king_pos == Vector2i(-1, -1):
		return false
	
	# can any oposing piece can move to position of king
	var oposing_team = InputManager.TeamColor.WHITE if team == InputManager.TeamColor.BLACK else InputManager.TeamColor.BLACK
	for y in range(ChessConstants.BOARD_SIZE):
		for x in range(ChessConstants.BOARD_SIZE):
			var piece = board_state[y][x]
			if piece != null and piece.team == oposing_team:
				var moves = piece.get_opponent_valid_moves(self)
				if king_pos in moves:
					return true
	return false

func is_king_in_check_after_move(team: InputManager.TeamColor, to_pos: Vector2i) -> bool:
	# Simulate the move to check if the king is in check (for castling)
	# Find the king for the given team
	var king_pos: Vector2i = Vector2i(-1, -1)
	for y in range(ChessConstants.BOARD_SIZE):
		for x in range(ChessConstants.BOARD_SIZE):
			var piece = board_state[y][x]
			if piece != null and piece.team == team and piece.piece_type == ChessConstants.PIECE_TYPES.king:
				king_pos = Vector2i(x, y)
				break
	
	# king not found
	if king_pos == Vector2i(-1, -1):
		return false
	
	# Temporarily move the king to the new position
	var king_piece = board_state[king_pos.y][king_pos.x]
	board_state[king_pos.y][king_pos.x] = null
	board_state[to_pos.y][to_pos.x] = king_piece
	
	# Check if the king is in check at the new position
	var in_check = is_king_in_check(team)
	
	# Restore the original board state
	board_state[king_pos.y][king_pos.x] = king_piece
	board_state[to_pos.y][to_pos.x] = null  # Always null for castling
	
	return in_check

func is_checkmate(team: InputManager.TeamColor) -> bool:
	if not is_king_in_check(team):
		return false
	return any_valid_moves(team)

func is_stalemate(team: InputManager.TeamColor) -> bool:
	if is_king_in_check(team):
		return false
	return any_valid_moves(team)

func any_valid_moves(team: InputManager.TeamColor) -> bool:
	# Try every move for every piece on the team
	for y in range(ChessConstants.BOARD_SIZE):
		for x in range(ChessConstants.BOARD_SIZE):
			var piece = board_state[y][x]
			if piece != null and piece.team == team:
				var moves = piece.get_valid_moves(self)
				for move in moves:
					# Simulate move
					var original_piece = board_state[move.y][move.x]
					var from_pos = piece.board_position
					board_state[from_pos.y][from_pos.x] = null
					board_state[move.y][move.x] = piece
					piece.board_position = move
					var in_check = is_king_in_check(team)
					# Undo move
					board_state[from_pos.y][from_pos.x] = piece
					board_state[move.y][move.x] = original_piece
					piece.board_position = from_pos
					if not in_check:
						return false # Found a move that escapes check
	return true


func handle_duel_result(winner: Piece, looser: Piece):
	print(winner)
	print(duel_attacker)
	var attacker_wins = (winner == duel_attacker)
	
	if en_passant_duel_active:
		_handle_en_passant_duel_result(attacker_wins)
	else:
		_handle_regular_duel_result(attacker_wins)
	_cleanup_duel_state()

func _handle_en_passant_duel_result(attacker_wins: bool):
	if attacker_wins:
		print("Attacker wins en passant duel")
		# Move attacker to en passant landing square
		_move_piece_to_position(duel_attacker, en_passant_landing_square)
		# Remove captured pawn
		board_state[duel_defender.board_position.y][duel_defender.board_position.x] = null
	else:
		print("Defender wins en passant duel")
		# Remove attacker from board
		board_state[duel_attacker.board_position.y][duel_attacker.board_position.x] = null

func _handle_regular_duel_result(attacker_wins: bool):
	if attacker_wins:
		print("Attacker wins!")
		# Move attacker to defender's position
		_move_piece_to_position(duel_attacker, duel_defender.board_position)

	else:
		print("Defender wins!")
		# Remove attacker from board
		board_state[duel_attacker.board_position.y][duel_attacker.board_position.x] = null

func _move_piece_to_position(piece: Piece, new_position: Vector2i):
	# Remove piece from old position
	board_state[piece.board_position.y][piece.board_position.x] = null
	# Place piece in new position
	board_state[new_position.y][new_position.x] = piece
	piece.set_board_position(new_position, ChessConstants.TILE_SIZE)

func _cleanup_duel_state():
	duel_attacker = null
	duel_defender = null
	clear_en_passant_target()
	
	# Reset duel state
	en_passant_duel_active = false
	en_passant_landing_square = Vector2i(-1, -1)

func add_captured_piece(piece: Piece):
	if piece.team == InputManager.TeamColor.WHITE:
		captured_white_pieces.append(piece)
	else:
		captured_black_pieces.append(piece)
	print("Captured white pieces: ", captured_white_pieces)
	print("Captured black pieces: ", captured_black_pieces)

func update_points(piece: Piece):
	if piece.team == InputManager.TeamColor.WHITE:
		black_points += piece.point_value
	else:
		white_points += piece.point_value
	print("White points: ", white_points)
	print("Black points: ", black_points)

func check_game_status():
	var opposing_turn = get_opposing_turn()
	if is_checkmate(opposing_turn):
		print("Checkmate!")
		#game_state_changed.emit(ChessConstants.GameState.CHECKMATE)
		on_initiate_duel(last_moved_piece, get_team_king(opposing_turn))
	elif is_stalemate(opposing_turn):
		print("Stalemate!")
		#game_state_changed.emit(ChessConstants.GameState.STALEMATE)
	elif is_king_in_check(opposing_turn):
		print("Check!")

func get_team_king(team: InputManager.TeamColor) -> Piece:
	for y in range(ChessConstants.BOARD_SIZE):
		for x in range(ChessConstants.BOARD_SIZE):
			var piece = board_state[y][x]
			if piece != null and piece.team == team and piece.piece_type == ChessConstants.PIECE_TYPES.king:
				return piece
	return null

func get_opposing_turn() -> InputManager.TeamColor:
	var current_turn = get_current_turn()
	return InputManager.TeamColor.WHITE if current_turn == InputManager.TeamColor.BLACK else InputManager.TeamColor.BLACK

func check_game_over():
	print("Checking game over")
	var current_turn = get_current_turn()
	if is_king_captured(current_turn):
		print("Game over!")
		var team_winner = get_opposing_turn()
		print("Winner by Checkmate")
		#game_state_changed.emit(ChessConstants.GameState.GAME_OVER)
		end_game()
	elif is_stalemate(current_turn):
		print("Game over! Stalemate")
		#game_state_changed.emit(ChessConstants.GameState.GAME_OVER)
		end_game()

func is_king_captured(team: InputManager.TeamColor) -> bool:
	var king = get_team_king(team)
	if king == null:
		return true
	return false

func end_game():
	SceneManager.end_game()
