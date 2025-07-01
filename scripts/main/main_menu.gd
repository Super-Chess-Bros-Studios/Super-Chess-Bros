extends Control

@onready var play: Button = $UILayer/ButtonsContainer/Play

@onready var modal: PackedScene = preload("res://scenes/main/player_registration_modal.tscn")
# Signals that main will connect to
signal request_scene_change(scene_name)

# Cache the main node reference
var main_node: Node

# Button navigation
var buttons: Array[Button] = []
var current_button_index: int = 0

# Modal management
var current_modal: Control = null
var is_modal_open: bool = false

func _ready():
	# Set up button array with onready references
	buttons = [play]
	if buttons.size() > 0:
		buttons[current_button_index].grab_focus()
	
	# Connect the button signal to the function
	play.pressed.connect(_on_play_button_pressed)

func _on_cancel_button_pressed():
	emit_signal("request_scene_change", "title_screen")

func _on_play_button_pressed():
	# Prevent multiple modals from being created
	if is_modal_open:
		return
		
	var modal_instance = modal.instantiate()
	print("Modal created: ", modal_instance)
	
	# Connect modal signals
	modal_instance.modal_closed.connect(_on_modal_closed)
	
	add_child(modal_instance)
	current_modal = modal_instance
	is_modal_open = true
	
	# Disable input processing on main menu while modal is open
	set_process_input(false)
	

func _on_modal_closed():
	if current_modal:
		current_modal.queue_free()
		current_modal = null
	is_modal_open = false
	
	# Re-enable input processing on main menu
	set_process_input(true)
	
	# Restore focus to the current button
	if buttons.size() > 0:
		buttons[current_button_index].grab_focus()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		_on_cancel_button_pressed()
	elif event.is_action_pressed("ui_up"):
		_navigate_buttons(-1)
	elif event.is_action_pressed("ui_down"):
		_navigate_buttons(1)

func _navigate_buttons(direction: int):
	if buttons.size() == 0:
		return
	
	# Remove focus from current button
	buttons[current_button_index].release_focus()
	
	# Update index
	current_button_index = (current_button_index + direction) % buttons.size()
	if current_button_index < 0:
		current_button_index = buttons.size() - 1
	
	# Set focus to new button
	buttons[current_button_index].grab_focus()
