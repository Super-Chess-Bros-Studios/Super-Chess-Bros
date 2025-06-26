extends Control

class_name UI


# Cache the main node reference and game controller

signal request_scene_change(scene_name: String)

@onready var timer: Timer = $Timer

func _ready():
	
	# Connect timer timeout signal
	timer.timeout.connect(_on_timer_timeout)

func _on_start_button_pressed():
	timer.start()
	# Don't emit signal immediately - wait for timer

func _on_timer_timeout():
	# Timer finished, now transition to main menu
	request_scene_change.emit("main_menu")

# Optional: Handle direct input for quick start
func _input(event):
	if event.is_action_pressed("ui_accept"):
		_on_start_button_pressed()
