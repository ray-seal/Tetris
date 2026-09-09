extends Node2D

@export var food_scene: PackedScene

@export var spawn_min := Vector2(64, 176)
@export var spawn_max := Vector2(736, 424)

var current_food = null
var score := 0


func _ready():
	call_deferred("spawn_food")


func spawn_food():
	if current_food != null:
		return

	current_food = food_scene.instantiate()

	var spawn_x = randf_range(spawn_min.x, spawn_max.x)
	var spawn_y = randf_range(spawn_min.y, spawn_max.y)

	current_food.position = Vector2(spawn_x, spawn_y)

	get_parent().add_child(current_food)

	current_food.eaten.connect(_on_food_eaten)


func _on_food_eaten():
	var worm = get_parent().get_node("Worm")

	if worm:
		worm.grow_worm()

	score += 1

	current_food = null
	call_deferred("spawn_food")
