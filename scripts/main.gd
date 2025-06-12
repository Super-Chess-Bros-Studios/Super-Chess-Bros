extends Node2D

@export var board_scene: PackedScene  # Drag your Board.tscn here in the inspector

# Main scene manager for everything
func _ready():
	var board = board_scene.instantiate()
	add_child(board)
	
