extends Control

@onready var white_player_score = $HBoxContainer/WhitePlayerCaptures/WhitePlayerScore
@onready var black_player_score = $HBoxContainer/BlackPlayerCaptures/BlackPlayerScore

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	white_player_score.text = "0"
	black_player_score.text = "0"

func _ui_update_points(black_points: int, white_points: int):
	black_player_score.text = str(black_points)
	white_player_score.text = str(white_points)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
