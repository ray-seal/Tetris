extends Area2D

var flying := false
var throw_direction := 0
var speed := 700.0

var miss_insults = [
	"Parcel left in safe place",
	"My nan can throw better and she's dead.",
	"I'm putting attempted.",
	"Well done dickhead, next time try and actually deliver something."
]


func _process(delta):
	if not flying:
		return

	# Move only along the X axis
	global_position.x += throw_direction * speed * delta

	# Missed delivery
	if global_position.x < -100 or global_position.x > 1200:
		miss_delivery()


func throw_to(start_position: Vector2, direction: int):
	global_position = start_position
	throw_direction = direction
	flying = true
	show()

	if direction < 0:
		print("PARCEL THROWN LEFT")
	else:
		print("PARCEL THROWN RIGHT")


func reset_parcel():
	flying = false
	throw_direction = 0
	hide()


func miss_delivery():
	if not flying:
		return

	var insult = miss_insults[randi_range(0, miss_insults.size() - 1)]
	print(insult)

	var player = get_parent().get_node("Player")
	player.show_insult(insult)

	reset_parcel()


func _on_area_entered(area: Area2D):
	if area.is_in_group("delivery_targets"):
		var house = area.get_parent()

		print("PARCEL DELIVERED TO: ", house.name)

		var player = get_parent().get_node("Player")
		player.deliveries += 1
		player.update_delivery_count()

		print("TOTAL DELIVERIES: ", player.deliveries)

		reset_parcel()


func _draw():
	draw_rect(Rect2(-10, -10, 20, 20), Color.WHITE)
