extends Node

@export var stage_scene: PackedScene
func _ready() -> void:
	var stage = stage_scene.instantiate()
	add_child(stage)
