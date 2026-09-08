extends ColorRect

@export var speed := 150.0

func _process(delta: float) -> void:
	position.y += speed * delta
	
	if position.y > 1300:
		position.y = -100
		
