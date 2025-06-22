class_name GameManager
extends RefCounted

signal game_state_changed(new_state: ChessConstants.GameState)
signal piece_selected(piece: Piece)
signal piece_deselected()
signal turn_switched(new_team: ChessConstants.TeamColor)

var board_state: Array[Array] = []
var current_game_state: ChessConstants.GameState = ChessConstants.GameState.WHITE_TURN
var selected_piece: Piece = null

func _init():
	initialize_board_state()

func initialize_board_state():
	board_state.clear()
	for y in range(ChessConstants.BOARD_SIZE):
		var row: Array[Piece] = []
		row.resize(ChessConstants.BOARD_SIZE)
		for x in range(ChessConstants.BOARD_SIZE):
			row[x] = null
		board_state.append(row)

func get_piece_at_position(pos: Vector2i) -> Piece:
	if is_valid_position(pos):
		return board_state[pos.y][pos.x]
	return null

func set_piece_at_position(pos: Vector2i, piece: Piece):
	if is_valid_position(pos):
		board_state[pos.y][pos.x] = piece

func is_valid_position(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < ChessConstants.BOARD_SIZE and pos.y >= 0 and pos.y < ChessConstants.BOARD_SIZE

func can_player_act(player_id: ChessConstants.PlayerId) -> bool:
	var current_team = ChessConstants.get_team_from_game_state(current_game_state)
	var player_team = ChessConstants.get_team_from_player_id(player_id)
	return current_team == player_team and current_game_state != ChessConstants.GameState.GAME_OVER

func select_piece(piece: Piece) -> bool:
	if piece == null:
		return false
	
	var current_team = ChessConstants.get_team_from_game_state(current_game_state)
	if piece.team != current_team:
		return false
	
	selected_piece = piece
	piece_selected.emit(piece)
	return true

func deselect_piece():
	if selected_piece != null:
		selected_piece = null
		piece_deselected.emit()

func switch_turn():
	match current_game_state:
		ChessConstants.GameState.WHITE_TURN:
			current_game_state = ChessConstants.GameState.BLACK_TURN
		ChessConstants.GameState.BLACK_TURN:
			current_game_state = ChessConstants.GameState.WHITE_TURN
	
	var new_team = ChessConstants.get_team_from_game_state(current_game_state)
	game_state_changed.emit(current_game_state)
	turn_switched.emit(new_team)

func get_current_team() -> ChessConstants.TeamColor:
	return ChessConstants.get_team_from_game_state(current_game_state)

func is_game_over() -> bool:
	return current_game_state == ChessConstants.GameState.GAME_OVER

func end_game():
	current_game_state = ChessConstants.GameState.GAME_OVER
	game_state_changed.emit(current_game_state) 