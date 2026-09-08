extends Node2D

@export var speed := 150.0

var active := false


func _ready():
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


func _on_pickup_area_area_entered(area: Area2D) -> void:

	if area.get_parent().name == "Player":

		var player = area.get_parent()

		player.parcels += 5
		player.update_parcel_count()

		print("PARCEL PICKUP! +5")
		print("TOTAL PARCELS: ", player.parcels)

		active = false
		hide()
		set_process(false)
