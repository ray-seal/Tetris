extends CanvasLayer

@export var chocolate_product: Product
@export var cola_product: Product

func _on_chocolate_plus_pressed() -> void:
	var amount = $PhonePanel/ProductScroll/ProductList/ChocolateCard/ChocolateAmount
	amount.text = str(int(amount.text) + 1)
	update_order_total()
	
func _on_chocolate_minus_pressed() -> void:
	var amount = $PhonePanel/ProductScroll/ProductList/ChocolateCard/ChocolateAmount
	var current = int(amount.text)
	
	if current > 0:
		amount.text = str(current - 1)
		
	update_order_total()

func update_order_total() -> void:
	var chocolate_amount = int($PhonePanel/ProductScroll/ProductList/ChocolateCard/ChocolateAmount.text)
	var cola_amount = int($PhonePanel/ProductScroll/ProductList/ColaCard/ColaAmount.text)
	
	var chocolate_total = chocolate_amount * chocolate_product.wholesale_cost
	var cola_total = cola_amount * cola_product.wholesale_cost
	
	var total = chocolate_total + cola_total
	
	$PhonePanel/OrderTotal.text = "TOTAL: £%.2f" % total
	
func _on_cola_plus_pressed() -> void:
	var amount = $PhonePanel/ProductScroll/ProductList/ColaCard/ColaAmount
	amount.text = str(int(amount.text) +1)
	update_order_total()


func _on_cola_minus_pressed() -> void:
	var amount = $PhonePanel/ProductScroll/ProductList/ColaCard/ColaAmount
	var current = int(amount.text)
	
	if current > 0:
		amount.text = str(current - 1)
		
	update_order_total()
	
func _ready() -> void:
	visible = false
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_P:
		visible = not visible
