class_name GameManager
extends RefCounted

# Signals for game state changes and piece interactions
signal game_state_changed(new_state: ChessConstants.GameState)
signal piece_selected(piece: Piece)
signal piece_deselected()
signal turn_switched(new_team: ChessConstants.TeamColor)
signal piece_moved(piece: Piece, from_pos: Vector2i, to_pos: Vector2i)
signal initiate_duel(attacker: Piece, defender: Piece)
# Core game state variables
var board_state: Array[Array] = []  # 2D array representing the chess board
var current_game_state: ChessConstants.GameState = ChessConstants.GameState.WHITE_TURN  # Current game state
var selected_piece: Piece = null  # Currently selected piece
var duel_attacker: Piece = null
var duel_defender: Piece = null
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

func can_player_act(player_id: ChessConstants.PlayerId) -> bool:
	# Check if given player can act (it's their turn and game isn't over)
	var current_team = ChessConstants.get_team_from_game_state(current_game_state)
	var player_team = ChessConstants.get_team_from_player_id(player_id)
	return current_team == player_team and current_game_state != ChessConstants.GameState.GAME_OVER

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

func get_current_turn() -> ChessConstants.TeamColor:
	# Get which team's turn it currently is
	return ChessConstants.get_team_from_game_state(current_game_state)


func on_initiate_duel(attacker: Piece, defender: Piece) -> void:
	duel_attacker = attacker
	duel_defender = defender
	if(attacker.point_value < defender.point_value):
		var defecit = (defender.point_value - attacker.point_value)*5
		print("Handicap of ", defecit, "% is applied to the defender")
	initiate_duel.emit(attacker, defender)
	

func move_piece(piece: Piece, to_pos: Vector2i) -> bool:
	# Validate the move using the piece's get_valid_moves function
	if not is_valid_move(piece, to_pos):
		return false
	
	var from_pos = piece.board_position
	
	# Capture enemy piece if it's in the target position
	if is_enemy(to_pos, piece.team):
		on_initiate_duel(piece, get_piece_at_position(to_pos))
		piece_moved.emit(piece, from_pos, to_pos)
		return false
	
	# Move piece to new position
	board_state[from_pos.y][from_pos.x] = null  # Remove from old position
	board_state[to_pos.y][to_pos.x] = piece     # Place in new position
	
	piece.set_board_position(to_pos, ChessConstants.TILE_SIZE)
	
	# Emit signal for piece movement
	piece_moved.emit(piece, from_pos, to_pos)
	
	deselect_piece()
	switch_turn()


	return true

func is_valid_move(piece: Piece, to_pos: Vector2i) -> bool:
	# Check if the move is valid for the given piece
	if not is_valid_position(to_pos) or piece == null:
		return false
	
	# Get valid moves for the piece
	var valid_moves = piece.get_valid_moves(self)
	
	# Check if the target position is in the valid moves list
	return to_pos in valid_moves

func is_empty(pos: Vector2i) -> bool:
	# Check if position is empty (no piece)
	if not is_valid_position(pos):
		return false
	return board_state[pos.y][pos.x] == null

func is_enemy(pos: Vector2i, team: ChessConstants.TeamColor) -> bool:
	# Check if position contains an enemy piece
	if not is_valid_position(pos):
		return false
	var piece = board_state[pos.y][pos.x]
	return piece != null and piece.team != team

func capture_piece(attack_piece: Piece, capture_pos: Vector2i):
	var defence_piece = board_state[capture_pos.y][capture_pos.x]
	if defence_piece != null:
		defence_piece.queue_free()
	print("attacking piece: ", attack_piece.name)
	print("defending piece: ", defence_piece.name)

func handle_duel_result(winner: Piece):
	if winner == duel_attacker:
		board_state[duel_attacker.board_position.y][duel_attacker.board_position.x] = null  # Remove from old position
		board_state[duel_defender.board_position.y][duel_defender.board_position.x] = duel_attacker     # Place in new position
		duel_attacker.set_board_position(duel_defender.board_position, ChessConstants.TILE_SIZE)
		deselect_piece()
		duel_defender.queue_free()
		duel_defender = null
		duel_attacker = null
		switch_turn()
		
	else:
		board_state[duel_attacker.board_position.y][duel_attacker.board_position.x] = null
		deselect_piece()
		duel_attacker.queue_free()
		duel_attacker = null
		duel_defender = null
		switch_turn()
		
