extends CanvasLayer

@onready var inventory = get_tree().root.find_child("Inventory", true, false)

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
		
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.controls_locked = visible
		
		if visible:
			$PhonePanel/ProductScroll/ProductList/ColaCard/ColaMinus.grab_focus()

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
	
	inventory.add_product(chocolate_product, chocolate_amount)
	inventory.add_product(cola_product, cola_amount)
	inventory.add_product(crisps_product, crisps_amount)

	var delivery = get_tree().get_first_node_in_group("delivery")
	
	if delivery:
		if chocolate_amount > 0:
			delivery.product = chocolate_product
			delivery.quantity = chocolate_amount
			delivery.update_product_display()
			delivery.visible = true
			
		elif cola_amount > 0:
			var cola_box = delivery.duplicate()
			delivery.get_parent().add_child(cola_box)
			
			cola_box.product = cola_product
			cola_box.quantity = cola_amount
			cola_box.global_position = delivery.global_position + Vector3(0.6, 0, 0)
			cola_box.update_product_display()
			cola_box.visible = true
			
	print("Inventory Check")
	print("Chocolate: ", inventory.get_quantity(chocolate_product))
	print("Cola: ", inventory.get_quantity(cola_product))
	print("Crisps: ", inventory.get_quantity(crisps_product))
	
	# Reset quantities
	$PhonePanel/ProductScroll/ProductList/ChocolateCard/ChocolateAmount.text = "0"
	$PhonePanel/ProductScroll/ProductList/ColaCard/ColaAmount.text = "0"
	$PhonePanel/ProductScroll/ProductList/CrispsCard/CrispsAmount.text = "0"
	
	# Reset total
	$PhonePanel/OrderTotal.text = "TOTAL: £0.00"
	
	$PhonePanel/PlaceOrderButton.text = "ORDER PLACED"
	$PhonePanel/PlaceOrderButton.disabled = true
	
func _process(delta):
	if visible:
		$PhonePanel/ProductScroll/ProductList/ColaCard/ColaMinus.focus_mode = Control.FOCUS_ALL
		$PhonePanel/ProductScroll/ProductList/ColaCard/ColaPlus.focus_mode = Control.FOCUS_ALL
		$PhonePanel/ProductScroll/ProductList/CrispsCard/CrispsMinus.focus_mode = Control.FOCUS_ALL
		$PhonePanel/ProductScroll/ProductList/CrispsCard/CrispsPlus.focus_mode = Control.FOCUS_ALL
		$PhonePanel/ProductScroll/ProductList/ChocolateCard/ChocolateMinus.focus_mode = Control.FOCUS_ALL
		$PhonePanel/ProductScroll/ProductList/ChocolateCard/ChocolatePlus.focus_mode = Control.FOCUS_ALL
		$PhonePanel/PlaceOrderButton.focus_mode = Control.FOCUS_ALL
			
	
