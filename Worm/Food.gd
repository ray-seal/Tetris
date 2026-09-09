extends Node2D

signal eaten

@onready var food_sprite: Sprite2D = $FoodSprite
@onready var eat_area: Area2D = $EatArea

const FOOD_FRAMES = [
	0, 1, 2, 3, 4, 5, 6,
	7, 8, 9, 10, 11,
	13, 14, 15, 16, 17, 18, 19,
	20, 21, 22, 23, 24, 25, 26, 27
]

func _ready():
	randomize()

	food_sprite.hframes = 7
	food_sprite.vframes = 4
	food_sprite.frame = FOOD_FRAMES.pick_random()

func _on_eat_area_area_entered(area):
	eaten.emit()
	queue_free()
