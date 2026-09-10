extends Sprite2D

var lane_positions = [125.0, 400.0, 675.0]
var current_lane = 1
var touch_start_position = Vector2.ZERO
var touch_active = false
var deliveries := 0
var parcels := 10
var level_time := 60.0
var last_tap_time := -1.0
var double_tap_time := 0.3

# Chav is a separate scene
@export var chav_scene: PackedScene

# Existing hazards and pickups from the Road
var hazards: Array[Node] = []
var pickups: Array[Node] = []


func _ready():
	position.x = lane_positions[current_lane]

	$"../../GameUI/DeliveriesLabel".text = "DELIVERIES: 0"
	$"../../GameUI/ParcelsLabel".text = "PARCELS: " + str(parcels)
	$"../../GameUI/TimeLabel".text = "TIME: 60"

	# Game Over UI starts hidden
	$"../../GameOverUI".hide()

	# --------------------------------
	# FIND EXISTING ROAD OBJECTS
	# --------------------------------

	var traffic_car = find_node_by_name(get_tree().current_scene, "TrafficCar")
	var traffic_car2 = find_node_by_name(get_tree().current_scene, "TrafficCar2")
	var traffic_car3 = find_node_by_name(get_tree().current_scene, "TrafficCar3")
	var pothole = find_node_by_name(get_tree().current_scene, "Pothole")
	var parcel_stack = find_node_by_name(get_tree().current_scene, "ParcelStack")
	var clock = find_node_by_name(get_tree().current_scene, "Timer")

	if traffic_car:
		hazards.append(traffic_car)

	if traffic_car2:
		hazards.append(traffic_car2)

	if traffic_car3:
		hazards.append(traffic_car3)

	if pothole:
		hazards.append(pothole)

	if parcel_stack:
		pickups.append(parcel_stack)
		parcel_stack.hide()
		parcel_stack.set_process(false)

	if clock:
		pickups.append(clock)
		clock.hide()
		clock.set_process(false)

	print("HAZARDS FOUND: ", hazards.size())
	print("PICKUPS FOUND: ", pickups.size())

	# Start random spawning AFTER lists are populated
	start_random_spawning()


func find_node_by_name(node: Node, wanted_name: String) -> Node:

	if node.name == wanted_name:
		return node

	for child in node.get_children():

		var result = find_node_by_name(child, wanted_name)

		if result:
			return result

	return null


func update_delivery_count():
	$"../../GameUI/DeliveriesLabel".text = "DELIVERIES: " + str(deliveries)


func update_parcel_count():
	$"../../GameUI/ParcelsLabel".text = "PARCELS: " + str(parcels)


func _process(delta):

	level_time -= delta

	$"../../GameUI/TimeLabel".text = "TIME: " + str(ceil(level_time))
	$"../../GameUI/ParcelsLabel".text = "PARCELS: " + str(parcels)

	if level_time <= 0:

		level_time = 0

		print("TIME UP!")

		show_game_over("TIMES UP!")

		return

	if Input.is_action_just_pressed("ui_left"):
		move_left()

	if Input.is_action_just_pressed("ui_right"):
		move_right()

	if Input.is_action_just_pressed("ui_accept"):
		throw_parcel()


func show_insult(insult: String):

	var label = $"../../GameUI/InsultLabel"

	label.text = insult
	label.show()

	await get_tree().create_timer(2.0).timeout

	label.hide()


func throw_parcel():

	print("THROW BUTTON PRESSED")

	var parcel = $"../Parcel"

	if parcels <= 0:
		print("NO PARCELS LEFT!")
		return

	if parcel.flying:
		return

	# LEFT lane
	if current_lane == 0:

		parcel.throw_to(global_position, -1)
		parcels -= 1

	# MIDDLE lane
	elif current_lane == 1:

		print("MIDDLE LANE - NO THROW")

	# RIGHT lane
	elif current_lane == 2:

		parcel.throw_to(global_position, 1)
		parcels -= 1


func _input(event):

	if event is InputEventScreenTouch:

		if event.pressed:

			var current_time = Time.get_ticks_msec() / 1000.0

			# DOUBLE TAP = THROW PARCEL
			if last_tap_time >= 0.0 and current_time - last_tap_time <= double_tap_time:
				throw_parcel()
				last_tap_time = -1.0
				touch_active = false
				return

			last_tap_time = current_time

			touch_start_position = event.position
			touch_active = true

		elif touch_active:

			var swipe_distance = event.position.x - touch_start_position.x

			if abs(swipe_distance) > 50:

				if swipe_distance < 0:
					move_left()
				else:
					move_right()

			touch_active = false


func move_left():

	if current_lane > 0:

		current_lane -= 1

		$AnimatedSprite2D.play("up_left")

		var tween = create_tween()

		tween.tween_property(
			self,
			"position:x",
			lane_positions[current_lane],
			0.2
		)

		await tween.finished

		$AnimatedSprite2D.play("up")


func move_right():

	if current_lane < 2:

		current_lane += 1

		$AnimatedSprite2D.play("up_right")

		var tween = create_tween()

		tween.tween_property(
			self,
			"position:x",
			lane_positions[current_lane],
			0.2
		)

		await tween.finished

		$AnimatedSprite2D.play("up")


# --------------------------------
# CHAV
# --------------------------------

func spawn_chav():

	if not chav_scene:
		print("NO CHAV SCENE ASSIGNED!")
		return

	var chav = chav_scene.instantiate()

	get_parent().add_child.call_deferred(chav)

	await get_tree().process_frame

	chav.global_position = $"../ChavSpawn".global_position

	print("CHAV DEPLOYED!")


# --------------------------------
# RANDOM HAZARD
# --------------------------------

func spawn_random_hazard():

	# Occasionally spawn a Chav
	if chav_scene and randf() < 0.25:
		spawn_chav()
		return

	var available_hazards: Array[Node] = []

	for hazard in hazards:

		if not is_instance_valid(hazard):
			continue

		if hazard.name == "Chav":
			continue

		if "active" in hazard and hazard.active:
			continue

		available_hazards.append(hazard)

	if available_hazards.is_empty():
		print("NO AVAILABLE HAZARDS!")
		return

	var hazard = available_hazards.pick_random()

	var lane = randi_range(0, 2)

	var spawn_position = Vector2(
		lane_positions[lane],
		-150
	)

	if hazard.has_method("spawn_at"):
		hazard.spawn_at(spawn_position, lane_positions[lane])

		print(
			"HAZARD SPAWNED: ",
			hazard.name,
			" LANE: ",
			lane
		)


# --------------------------------
# RANDOM PICKUP
# --------------------------------

func spawn_random_pickup():

	if pickups.is_empty():
		print("NO PICKUPS FOUND!")
		return

	var available_pickups: Array[Node] = []

	for pickup in pickups:

		if not is_instance_valid(pickup):
			continue

		if "active" in pickup and pickup.active:
			continue

		available_pickups.append(pickup)

	if available_pickups.is_empty():
		print("NO AVAILABLE PICKUPS!")
		return

	var pickup = available_pickups.pick_random()

	var lane = randi_range(0, 2)

	var spawn_position = Vector2(
		lane_positions[lane],
		-150
	)

	if pickup.has_method("spawn_at"):
		pickup.spawn_at(spawn_position, lane_positions[lane])

		print(
			"PICKUP SPAWNED: ",
			pickup.name,
			" LANE: ",
			lane
		)


# --------------------------------
# RANDOM SPAWN TEST
# --------------------------------

func test_random_spawn():

	var spawn_type = randi_range(0, 1)

	if spawn_type == 0:
		spawn_random_hazard()
	else:
		spawn_random_pickup()


# --------------------------------
# GAME OVER
# --------------------------------

func show_game_over(message: String):

	print("GAME OVER: ", message)

	set_process(false)
	set_physics_process(false)

	$"../../GameOverUI".show()

	$"../../GameOverUI/Label".text = message
	$"../../GameOverUI/Label".show()

	$"../../GameOverUI/Fade".show()
	$"../../GameOverUI/PlayAgain".show()
	$"../../GameOverUI/BackToArcade".show()


# --------------------------------
# PLAYER COLLISIONS
# --------------------------------

func _on_area_2d_area_entered(area: Area2D):

	if area.get_parent().name in ["TrafficCar", "TrafficCar2", "TrafficCar3"]:

		print("TRAFFIC CAR HIT!")

		show_game_over("SQUISH!!")

		return


	if area.get_parent().name == "Chav":

		print("CHAV HIT!")

		show_game_over("Watch it bruv!")

		return


	if area.get_parent().is_in_group("time_pickups"):

		var clock = area.get_parent()

		level_time += clock.time_bonus

		print(
			"CLOCK PICKED UP! +",
			clock.time_bonus,
			" SECONDS"
		)

		clock.queue_free()

		return


	if area.get_parent().name == "Pothole":

		print("POTHOLE!")

		# Stop the player
		set_process(false)
		set_physics_process(false)

		# Play falling animation
		var tween = create_tween()

		tween.set_parallel(true)

		tween.tween_property(
			self,
			"scale",
			Vector2(0.1, 0.1),
			0.5
		)

		tween.tween_property(
			self,
			"rotation",
			deg_to_rad(90),
			0.5
		)

		tween.tween_property(
			self,
			"modulate:a",
			0.0,
			0.5
		)

		await tween.finished

		show_game_over("Can't park there, sir!")


func start_random_spawning():

	while is_processing():

		# Wait a random amount of time
		await get_tree().create_timer(randf_range(2.0, 4.0)).timeout

		# 70% chance of hazard
		# 30% chance of pickup
		if randf() < 0.7:
			spawn_random_hazard()
		else:
			spawn_random_pickup()
