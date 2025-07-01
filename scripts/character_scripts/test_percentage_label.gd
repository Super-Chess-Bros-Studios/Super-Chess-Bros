extends Label
@export var char_attributes : CharacterAttributes

func _physics_process(delta: float) -> void:
	self.text = str("Percentage: ", char_attributes.percentage)
