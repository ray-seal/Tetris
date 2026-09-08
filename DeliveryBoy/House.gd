extends Node2D

@export var speed := 150.0

func _ready():
	randomize()
	choose_random_house()


func _process(delta: float) -> void:
	position.y += speed * delta
	
	if position.y > 1300:
		position.y = -300
		choose_random_house()


func choose_random_house():
	# Hide all houses
	for child in get_children():
		if child is AnimatedSprite2D:
			child.visible = false
	
	# Pick a random house
	var house_number = randi_range(1, 8)
	
	# Show selected house
	var house = get_node("House" + str(house_number))
	house.visible = true
	
	# Try the LEFT side first
	position.x = 200
	
	# Wait one physics frame so the collision system updates
	await get_tree().physics_frame
	
	# Check whether another HouseOccupied area is already here
	var occupied = false
	
	if has_node("HouseOccupied"):
		var house_occupied = $HouseOccupied
		
		for area in house_occupied.get_overlapping_areas():
			if area != house_occupied and area.name == "HouseOccupied":
				occupied = true
				break
	
	# If left is occupied, use the RIGHT side
	if occupied:
		position.x = 970
	
	# LEFT = normal
	# RIGHT = mirrored
	if position.x < 400:
		house.flip_h = false
	else:
		house.flip_h = true
	
	# Scale the house
	scale = Vector2(0.3, 0.3)
	
	print("Selected house: ", house_number, " | X: ", position.x, " | Occupied: ", occupied)

func get_delivery_target() -> Area2D:
	if has_node("DeliveryTarget"):
		return $DeliveryTarget
	return null
