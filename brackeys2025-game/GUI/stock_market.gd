extends MarginContainer

var products_in_demand : Array[Globals.products] = []

func _ready():
	_on_change_product_timer_timeout()

func price_lookup(product : Globals.products):
	
	var base_price = Globals.product_recipes[product].purchase_price
	var supply_demand_factor = 1.0
	
	var adj_price = base_price * supply_demand_factor

func _on_change_product_timer_timeout():
	var random_product = Globals.products.values().pick_random()
	if not products_in_demand.has(random_product):
		products_in_demand.push_front(random_product)
		if products_in_demand.size() > 3:
			# discard old products
			products_in_demand.pop_back()
	Globals.products_in_demand = products_in_demand
	
	var label = $ProductDemandLabel
	label.text = "Products in demand: "
	for product in products_in_demand:
		label.text += Globals.product_recipes[product].product_name
		if product != products_in_demand[-1]:
			# not the last product
			label.text += ", "
	
