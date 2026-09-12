extends CSGBox3D

@export var product: Product
@export var quantity: int = 1

@onready var chocolate_label = $ChocolateLabel
@onready var cola_label = $ColaLabel

@onready var chocolate_image = $ChocolateImage
@onready var cola_image = $ColaImage

@onready var interaction_area = $InteractionArea

func _ready() -> void:
	interaction_area.monitoring = true
	update_product_display()
	
func update_product_display() -> void:
	chocolate_label.visible = false
	cola_label.visible = false
	
	chocolate_image.visible = false
	cola_image.visible = false
	
	if product == null:
		return
		
	if product.product_name.contains("Chocolate"):
		chocolate_label.visible = true
		chocolate_image.visible = true
		
	elif product.product_name.contains("Cola"):
		cola_label.visible = true
		cola_image.visible = true

func set_product(new_product: Product) -> void:
	product = new_product
	update_product_display()
