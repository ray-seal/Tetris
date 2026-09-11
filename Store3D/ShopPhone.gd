extends CanvasLayer

@export var chocolate_product: Product
@export var cola_product: Product
@export var crisps_product: Product

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
	var crisps_amount = int($PhonePanel/ProductScroll/ProductList/CrispsCard/CrispsAmount.text)
	
	var chocolate_total = chocolate_amount * chocolate_product.wholesale_cost
	var cola_total = cola_amount * cola_product.wholesale_cost
	var crisps_total = crisps_amount * crisps_product.wholesale_cost
	
	var total = chocolate_total + cola_total + crisps_total
	
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
	$PhonePanel/PlaceOrderButton.text = "PLACE ORDER"
	$PhonePanel/PlaceOrderButton.disabled = false
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_P:
		visible = not visible

		if visible:
			$PhonePanel/PlaceOrderButton.text = "PLACE ORDER"
			$PhonePanel/PlaceOrderButton.disabled = false

func _on_crisps_plus_pressed() -> void:
	var amount = $PhonePanel/ProductScroll/ProductList/CrispsCard/CrispsAmount
	amount.text = str(int(amount.text) + 1)
	update_order_total()


func _on_crisps_minus_pressed() -> void:
	var amount = $PhonePanel/ProductScroll/ProductList/CrispsCard/CrispsAmount
	var current = int(amount.text)
	
	if current > 0:
		amount.text = str(current - 1)
		
	update_order_total()


func _on_place_order_button_pressed() -> void:
	var chocolate_amount = int($PhonePanel/ProductScroll/ProductList/ChocolateCard/ChocolateAmount.text)
	var cola_amount = int($PhonePanel/ProductScroll/ProductList/ColaCard/ColaAmount.text)
	var crisps_amount = int($PhonePanel/ProductScroll/ProductList/CrispsCard/CrispsAmount.text)
	
	print("ORDER PLACED")
	print("Chocolate Bars: ", chocolate_amount)
	print("Cola: ", cola_amount)
	print("Crisps", crisps_amount)
	
	# Reset quantities
	$PhonePanel/ProductScroll/ProductList/ChocolateCard/ChocolateAmount.text = "0"
	$PhonePanel/ProductScroll/ProductList/ColaCard/ColaAmount.text = "0"
	$PhonePanel/ProductScroll/ProductList/CrispsCard/CrispsAmount.text = "0"
	
	# Reset total
	$PhonePanel/OrderTotal.text = "TOTAL: £0.00"
	
	$PhonePanel/PlaceOrderButton.text = "ORDER PLACED"
	$PhonePanel/PlaceOrderButton.disabled = true
