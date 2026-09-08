extends Node2D

@export var time_bonus := 10.0
@export var speed := 150.0

var active := false


func _ready():
	add_to_group("time_pickups")
	hide()
	set_process(false)


func _process(delta):
	position.y += speed * delta

	if position.y > 1300:
		active = false
		hide()
		set_process(false)


func spawn_at(spawn_position: Vector2, lane_x: float):

	position = Vector2(lane_x, spawn_position.y)

	active = true
	show()
	set_process(true)
