extends Control

# Signal to notify parent when modal should be closed
signal modal_closed

# Player registration state
var white_player_registered: bool = false
var black_player_registered: bool = false
var white_device_type: String = ""
var black_device_type: String = ""

@onready var white_status: Label = $ModalContainer/VBoxContainer/PlayersContainer/WhiteSide/WhiteStatus
@onready var black_status: Label = $ModalContainer/VBoxContainer/PlayersContainer/BlackSide/BlackStatus


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Grab focus so this node can receive input events
	grab_focus()
	
	# Make sure the modal is visible and properly sized
	show()
	
	# Initialize labels
	_update_labels()

func _input(event):
	# Handle modal-specific input
	if event.is_action_pressed("ui_cancel"):
		if white_player_registered and black_player_registered:
			# Both players registered, restart registration process
			_restart_registration()
		else:
			# Not both registered, close modal
			_close_modal()
		# Accept the event so it doesn't propagate to parent
		get_viewport().set_input_as_handled()
	
	# Handle player registration (only if both players aren't already registered)
	if event.is_action_pressed("ui_accept"):
		if not (white_player_registered and black_player_registered):
			var device_id = _get_device_id(event)
			print("Device ID from event: ", device_id)
			_register_player(event)
	
	var input_manager = get_node("/root/Main").get_input_manager()
	if input_manager.is_correct_device_type("white", event):
		if event.is_action_pressed(input_manager.get_action("right", "white")):
			print("White input")
	if input_manager and input_manager.is_correct_device_type("black", event):
		if event.is_action_pressed(input_manager.get_action("right", "black")):
			print("Black input")

func _register_player(event):
	var device_type = _get_device_type(event)
	var device_id = _get_device_id(event)
	var device_name = _get_device_name(device_id, device_type)
	
	if not white_player_registered:
		# Register white player
		white_player_registered = true
		white_device_type = device_type
		_update_input_manager_white_device(device_type, device_id, device_name)
		_update_labels()
		print("White player registered with device: ", device_type, " ID: ", device_id)
		
	elif not black_player_registered:
		# Register black player
		black_player_registered = true
		black_device_type = device_type
		_update_input_manager_black_device(device_type, device_id, device_name)
		_update_labels()
		print("Black player registered with device: ", device_type, " ID: ", device_id)
		

func _restart_registration():
	# Reset registration state
	white_player_registered = false
	black_player_registered = false
	white_device_type = ""
	black_device_type = ""
	
	# Clear devices in input manager
	var main_node = get_node("/root/Main")
	if main_node and main_node.has_method("get_input_manager"):
		var input_manager = main_node.get_input_manager()
		if input_manager:
			input_manager.clear_player_devices()
	
	# Update labels to show restart state
	_update_labels()
	print("Registration restarted - both players cleared")

func _get_device_type(event) -> String:
	if event is InputEventKey:
		return "keyboard"
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		return "controller"
	else:
		return "unknown"

func _get_device_id(event) -> int:
	if event is InputEventJoypadButton:
		return event.device
	elif event is InputEventJoypadMotion:
		return event.device
	else:
		return 0  # Keyboard

func _get_device_name(device_id: int, device_type: String) -> String:
	if device_type == "controller" and device_id >= 0:
		return Input.get_joy_name(device_id)
	elif device_type == "keyboard":
		return "Keyboard"
	else:
		return "Unknown Device"

func _update_input_manager_white_device(device_type: String, device_id: int, device_name: String):
	var main_node = get_node("/root/Main")
	if main_node and main_node.has_method("get_input_manager"):
		var input_manager = main_node.get_input_manager()
		if input_manager:
			input_manager.set_white_player_device(device_type, device_id+1, device_name) # device_id + 1 because device_id is 0-indexed

func _update_input_manager_black_device(device_type: String, device_id: int, device_name: String):
	var main_node = get_node("/root/Main")
	if main_node and main_node.has_method("get_input_manager"):
		var input_manager = main_node.get_input_manager()
		if input_manager:
			input_manager.set_black_player_device(device_type, device_id + 1, device_name) # device_id + 1 because device_id is 0-indexed



func _update_labels():
	# Always show current registration status
	if white_status:
		if white_player_registered:
			white_status.text = "White: Ready (" + white_device_type + ")"
		else:
			white_status.text = "White: Press Enter/Start to register"
	
	if black_status:
		if black_player_registered:
			black_status.text = "Black: Ready (" + black_device_type + ")"
		else:
			black_status.text = "Black: Press Enter/Start to register"
	
	# Add reregister message when both are registered
	if white_player_registered and black_player_registered:
		if white_status:
			white_status.text += "\nPress Cancel to reregister controllers"

func _close_modal():
	# Emit signal to notify parent that modal should be closed
	modal_closed.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
