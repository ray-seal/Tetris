extends Node

var items: Dictionary = {}

func add_product(product: Product, quantity: int) -> void:
	if product == null or quantity <= 0:
		return
		
	if items.has(product):
		items[product] += quantity
	else:
		items[product] = quantity
		
func remove_product(product: Product, quantity: int) -> void:
	if product == null or quantity <=0:
		return
			
	if not items.has(product):
		return
			
	items[product] -= quantity
		
	if items[product] <= 0:
		items.erase(product)
			
			
func get_quantity(product: Product) -> int:
	if product == null:
		return 0
				
	return items.get(product, 0)
