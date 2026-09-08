extends Sprite2D

@export var speed := 150.0

var active := false


func _ready():
	hide()
	set_process(false)


func _process(delta: float) -> void:

	position.y += speed * delta

	if position.y > 1100:
		active = false
		hide()
		set_process(false)


func spawn_at(spawn_position: Vector2, lane_x: float):

	position = Vector2(lane_x, spawn_position.y)

	active = true
	show()
	set_process(true)
