extends Node2D

func _ready():
	print("Dual arena loaded!")
	
	# Create a simple UI for testing
	var label = Label.new()
	label.text = "DUAL ARENA - Press ESC to return to chess"
	label.position = Vector2(100, 100)
	add_child(label)

func _input(event):
	# Exit on cancel
	if event.is_action_pressed("ui_cancel"):
		var main_node = get_node("/root/Main")
		if main_node:
			main_node.request_duel_exit() 