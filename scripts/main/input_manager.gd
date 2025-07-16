extends Node

# Player device tracking
var white_player_device: Dictionary = {}
var black_player_device: Dictionary = {}

func _ready() -> void:
	initialize_player_devices()
	controller_keyboard_setup()

func initialize_player_devices():
	white_player_device = {
		"device_type": "",
		"device_id": -1,
		"device_name": ""
	}
	black_player_device = {
		"device_type": "",
		"device_id": -1,
		"device_name": ""
	}

func controller_keyboard_setup():
	white_player_device = {
		"device_type": "keyboard",
		"device_id": 0,
		"device_name": "White"
	}
	black_player_device = {
		"device_type": "controller",
		"device_id": 0,
		"device_name": "Black"
	}
func controller_only_setup():
	white_player_device = {
		"device_type": "controller",
		"device_id": 0,
		"device_name": "White"
	}
	black_player_device = {
		"device_type": "controller",
		"device_id": 1,
		"device_name": "Black"
	}

# Player device management
func set_white_player_device(device_type: String, device_id: int = -1, device_name: String = ""):
	white_player_device = {
		"device_type": device_type,
		"device_id": device_id,
		"device_name": device_name
	}
	print("White player device set: ", white_player_device)

func set_black_player_device(device_type: String, device_id: int = -1, device_name: String = ""):
	black_player_device = {
		"device_type": device_type,
		"device_id": device_id,
		"device_name": device_name
	}
	print("Black player device set: ", black_player_device)

func get_action(action_base: String, id: int) -> String:
	#1 is white and 2 is black
	if id == 1:
		var device_type = white_player_device.get("device_type", "")
		if device_type == "controller":
			var device_id = white_player_device.get("device_id", -1)
			return "%s_%d" % [action_base, device_id + 1]
		else:
			return "%s_kb" % action_base
	elif id == 2:
		var device_type = black_player_device.get("device_type", "")
		if device_type == "controller":
			var device_id = black_player_device.get("device_id", -1)
			return "%s_%d" % [action_base, device_id + 1]
		else:
			return "%s_kb" % action_base
	return "pass"

func get_device_type(event) -> String:
	if event is InputEventKey:
		return "keyboard"
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		return "controller"
	return "unknown"


func get_white_player_device() -> Dictionary:
	return white_player_device.duplicate()

func get_black_player_device() -> Dictionary:
	return black_player_device.duplicate()

func clear_player_devices():
	initialize_player_devices()
	print("Player devices cleared")
